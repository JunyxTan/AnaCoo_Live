import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../core/formatting.dart';
import '../../data/database.dart';
import '../../data/enums.dart';
import '../../data/extensions.dart';
import '../../data/job_repository.dart';
import '../../domain/parser/appointment_request_parser.dart';
import '../../domain/scheduling.dart';
import '../../domain/service_labels.dart';
import '../../domain/shop_time.dart';
import '../../l10n/app_strings.dart';
import '../../providers/providers.dart';
import '../widgets/common.dart';
import '../widgets/job_photos_section.dart';
import 'reminder_editor.dart';

/// Create or edit a job, with both of its appointments.
///
/// The screen is deliberately one page: a drop-off and a collection are two
/// halves of the same decision, and splitting them across steps is how a
/// collection date ends up never being set.
class JobEditorScreen extends ConsumerStatefulWidget {
  const JobEditorScreen({
    super.key,
    this.jobId,
    this.initialDraft,
    this.parsed,
    this.seedCollectionAt,
    this.onSaved,
    this.onDeleted,
  });

  /// Editing an existing job.
  final int? jobId;

  /// Pre-filled draft, from a parsed message or a tapped calendar slot.
  final JobDraft? initialDraft;

  /// Present when this screen was opened from an import, so the unmatched
  /// pieces of the message can be shown alongside the fields.
  final ParsedRequest? parsed;

  /// When opening an existing job that still has no collection, pre-fill one
  /// at this shop-local time (e.g. after marking the job ready).
  final tz.TZDateTime? seedCollectionAt;

  final void Function(int jobId)? onSaved;

  /// Called just before the screen closes on a delete, so the page underneath
  /// can close too rather than show a job that is gone.
  final VoidCallback? onDeleted;

  @override
  ConsumerState<JobEditorScreen> createState() => _JobEditorScreenState();
}

class _JobEditorScreenState extends ConsumerState<JobEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerFocus = FocusNode();

  late JobDraft _draft;
  late TextEditingController _name;
  late TextEditingController _phone;
  late TextEditingController _item;
  late TextEditingController _quantity;
  late TextEditingController _price;
  late TextEditingController _deposit;
  late TextEditingController _notes;

  bool _loading = true;
  bool _saving = false;
  int? _selectedCustomerId;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    final draft = widget.initialDraft ?? _blankDraft();
    if (widget.jobId != null) {
      final db = ref.read(databaseProvider);
      final job = await db.getJob(widget.jobId!);
      final customer = await db.getCustomer(job.customerId);
      final dropOff = await db.appointmentOf(job.id, AppointmentType.dropOff);
      final collection =
          await db.appointmentOf(job.id, AppointmentType.collection);
      draft
        ..jobId = job.id
        ..customerId = customer.id
        ..customerName = customer.name
        ..phone = customer.phone
        ..whatsappNumber = customer.whatsappNumber
        ..service = job.service
        ..serviceFreeText = job.serviceFreeText
        ..itemDescription = job.itemDescription
        ..quantity = job.quantity
        ..quotedPrice = job.quotedPrice
        ..depositPaid = job.depositPaid
        ..status = job.status
        ..isRush = job.isRush
        ..notes = job.notes
        ..rawMessage = job.rawMessage
        ..dropOff = dropOff == null
            ? draft.dropOff
            : AppointmentDraft.fromRow(dropOff)
        ..collection =
            collection == null ? null : AppointmentDraft.fromRow(collection);
    }

    if (draft.collection == null && widget.seedCollectionAt != null) {
      draft.collection = AppointmentDraft(at: widget.seedCollectionAt!);
    }

    _draft = draft;
    _selectedCustomerId = draft.customerId;
    _name = TextEditingController(text: draft.customerName);
    _phone = TextEditingController(text: draft.phone ?? '');
    _item = TextEditingController(text: draft.itemDescription ?? '');
    _quantity = TextEditingController(text: '${draft.quantity}');
    _price = TextEditingController(
      text: draft.quotedPrice == null ? '' : draft.quotedPrice!.toStringAsFixed(2),
    );
    _deposit = TextEditingController(
      text: draft.depositPaid == null ? '' : draft.depositPaid!.toStringAsFixed(2),
    );
    _notes = TextEditingController(text: draft.notes ?? '');

    if (!mounted) return;
    setState(() => _loading = false);
    // An imported message without a name still needs the customer field first.
    if (widget.parsed != null && draft.customerName.trim().isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _customerFocus.requestFocus(),
      );
    }
  }

  JobDraft _blankDraft() {
    final hours = ref.read(workingHoursProvider);
    final slot = ref.read(slotMinutesProvider);
    return JobDraft(
      dropOff: AppointmentDraft(
        at: snapIntoWorkingHours(shopNow(), hours, slotMinutes: slot),
      ),
    );
  }

  @override
  void dispose() {
    _customerFocus.dispose();
    if (!_loading) {
      _name.dispose();
      _phone.dispose();
      _item.dispose();
      _quantity.dispose();
      _price.dispose();
      _deposit.dispose();
      _notes.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);
    final language = ref.watch(languageCodeProvider);

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_draft.isNew ? strings.newJob : strings.edit),
        actions: [
          IconButton(
            tooltip: strings.save,
            onPressed: _saving ? null : _save,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
          children: [
            if (widget.parsed != null) _ImportSummary(parsed: widget.parsed!),
            SectionHeader(strings.customer, icon: Icons.person_outline),
            _customerSection(strings),
            SectionHeader(strings.service, icon: Icons.design_services_outlined),
            _serviceSection(strings, language),
            SectionHeader(strings.dropOff, icon: Icons.download_outlined),
            _AppointmentEditor(
              draft: _draft.dropOff,
              type: AppointmentType.dropOff,
              excludeId: null,
              onChanged: (next) => setState(() => _draft.dropOff = next),
            ),
            SectionHeader(strings.collection, icon: Icons.upload_outlined),
            _collectionSection(strings),
            const SizedBox(height: 20),
            if (widget.jobId != null)
              JobPhotosSection(jobId: widget.jobId!)
            else
              SectionCard(
                title: strings.clothPhotos,
                icon: Icons.photo_library_outlined,
                child: Text(
                  strings.saveJobToAddPhotos,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            SectionHeader(strings.notes, icon: Icons.notes_outlined),
            TextFormField(
              controller: _notes,
              minLines: 3,
              maxLines: 8,
              decoration: InputDecoration(hintText: strings.notes),
            ),
            if (_draft.rawMessage != null) ...[
              SectionHeader(strings.rawMessage),
              _RawMessageBlock(text: _draft.rawMessage!),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.check),
              label: Text(strings.save),
            ),
            // Well below Save, and only for a job that exists: the one
            // irreversible action on this page should be hard to hit by
            // accident.
            if (widget.jobId != null) ...[
              const SizedBox(height: 32),
              TextButton.icon(
                onPressed: _saving ? null : _confirmDelete,
                icon: const Icon(Icons.delete_outline),
                label: Text(strings.delete),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _customerSection(AppStrings strings) {
    final customers = ref.watch(customersProvider('')).value ?? const <Customer>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _name,
          focusNode: _customerFocus,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: strings.name,
            prefixIcon: const Icon(Icons.person_outline),
          ),
          onChanged: (_) => setState(() => _selectedCustomerId = null),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _phone,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: strings.phone,
            prefixIcon: const Icon(Icons.phone_outlined),
          ),
          onChanged: (_) => setState(() => _selectedCustomerId = null),
        ),
        const SizedBox(height: 8),
        IconButton.outlined(
          tooltip: strings.pickFromContacts,
          onPressed: _pickContact,
          icon: const Icon(Icons.contacts_outlined),
        ),
        if (customers.isNotEmpty && _selectedCustomerId == null)
          _CustomerSuggestions(
            customers: customers,
            query: _name.text.isEmpty ? _phone.text : _name.text,
            onPick: (customer) => setState(() {
              _selectedCustomerId = customer.id;
              _name.text = customer.name;
              _phone.text = customer.phone ?? '';
              _draft.whatsappNumber = customer.whatsappNumber;
            }),
          ),
      ],
    );
  }

  Widget _serviceSection(AppStrings strings, String language) {
    final unmatched = widget.parsed?.service;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<ServiceType?>(
          initialValue: _draft.service,
          isExpanded: true,
          decoration: InputDecoration(labelText: strings.service),
          items: [
            DropdownMenuItem<ServiceType?>(
              child: Text('— ${strings.none} —'),
            ),
            for (final service in ServiceType.values)
              DropdownMenuItem<ServiceType?>(
                value: service,
                child: Text(serviceLabel(service, language)),
              ),
          ],
          onChanged: (value) => setState(() => _draft.service = value),
        ),
        if (_draft.service == null &&
            unmatched != null &&
            unmatched.rawText.isNotEmpty) ...[
          const SizedBox(height: 8),
          _UnmatchedChip(
            label: strings.serviceCouldNotMatch,
            value: unmatched.rawText,
            help: strings.serviceCouldNotMatchHelp,
          ),
        ],
        if (_draft.service == ServiceType.other) ...[
          const SizedBox(height: 12),
          TextFormField(
            initialValue: _draft.serviceFreeText,
            decoration: InputDecoration(labelText: strings.service),
            onChanged: (value) => _draft.serviceFreeText = value,
          ),
        ],
        const SizedBox(height: 12),
        TextFormField(
          controller: _item,
          decoration: InputDecoration(labelText: strings.itemDescription),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _quantity,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: strings.quantity),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _price,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: strings.quotedPrice),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _deposit,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: strings.depositPaid),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _draft.isRush,
          title: Text(strings.rushJob),
          onChanged: (value) => setState(() => _draft.isRush = value),
        ),
      ],
    );
  }

  Widget _collectionSection(AppStrings strings) {
    final collection = _draft.collection;
    if (collection == null) {
      return OutlinedButton.icon(
        onPressed: _addSuggestedCollection,
        icon: const Icon(Icons.event_available_outlined),
        label: Text(strings.addCollection),
      );
    }
    return Column(
      children: [
        _AppointmentEditor(
          draft: collection,
          type: AppointmentType.collection,
          excludeId: null,
          onChanged: (next) => setState(() => _draft.collection = next),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            tooltip: strings.setLater,
            onPressed: () => setState(() => _draft.collection = null),
            icon: const Icon(Icons.schedule_outlined),
          ),
        ),
      ],
    );
  }

  void _addSuggestedCollection() {
    final hours = ref.read(workingHoursProvider);
    final slot = ref.read(slotMinutesProvider);
    final turnaround = ref.read(turnaroundDaysProvider);
    setState(() {
      _draft.collection = AppointmentDraft(
        at: suggestCollection(
          _draft.dropOff.at,
          hours,
          turnaroundDays: turnaround,
          slotMinutes: slot,
        ),
      );
    });
  }

  Future<void> _pickContact() async {
    final strings = ref.read(appStringsProvider);
    try {
      await FlutterContacts.permissions.request(PermissionType.read);
      Contact? contact;
      try {
        contact = await FlutterContacts.native
            .showPicker(properties: {ContactProperty.phone});
      } on Exception {
        // Android throws when READ_CONTACTS was refused; the permissionless
        // picker still gives us a name.
        contact = await FlutterContacts.native.showPicker();
      }
      if (contact == null || !mounted) return;
      setState(() {
        _selectedCustomerId = null;
        _name.text = contact!.displayName ?? _name.text;
        if (contact.phones.isNotEmpty) _phone.text = contact.phones.first.number;
      });
    } on Exception {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.pickFromContacts)),
      );
    }
  }

  Future<void> _save() async {
    final strings = ref.read(appStringsProvider);
    _draft
      ..customerId = _selectedCustomerId
      ..customerName = _name.text.trim()
      ..phone = _phone.text.trim().isEmpty ? null : _phone.text.trim()
      ..itemDescription = _item.text.trim().isEmpty ? null : _item.text.trim()
      ..quantity = int.tryParse(_quantity.text.trim()) ?? 1
      ..quotedPrice = double.tryParse(_price.text.trim().replaceAll(',', '.'))
      ..depositPaid = double.tryParse(_deposit.text.trim().replaceAll(',', '.'))
      ..notes = _notes.text.trim().isEmpty ? null : _notes.text.trim();

    // The one hard rule: a job must belong to somebody we can contact.
    if (!_draft.hasIdentifiableCustomer) {
      _customerFocus.requestFocus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.customerRequired)),
      );
      return;
    }

    setState(() => _saving = true);
    final repository = ref.read(jobRepositoryProvider);
    final jobId = await repository.save(_draft);
    if (!mounted) return;
    setState(() => _saving = false);
    widget.onSaved?.call(jobId);
    Navigator.of(context).pop(jobId);
  }

  Future<void> _confirmDelete() async {
    final jobId = widget.jobId;
    if (jobId == null) return;
    final strings = ref.read(appStringsProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(strings.deleteJobConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(strings.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    // Block Save while the delete runs, so a double tap cannot resurrect the
    // job it just removed.
    setState(() => _saving = true);
    await ref.read(jobRepositoryProvider).deleteJob(jobId);
    if (!mounted) return;
    widget.onDeleted?.call();
    Navigator.of(context).pop();
  }
}

/// Date, time, duration and reminders for one appointment, with the scheduling
/// warnings shown directly underneath.
class _AppointmentEditor extends ConsumerWidget {
  const _AppointmentEditor({
    required this.draft,
    required this.type,
    required this.excludeId,
    required this.onChanged,
  });

  final AppointmentDraft draft;
  final AppointmentType type;
  final int? excludeId;
  final ValueChanged<AppointmentDraft> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final language = ref.watch(languageCodeProvider);
    final formats = Formats(language);
    final hours = ref.watch(workingHoursProvider);
    final blocked = ref.watch(blockedDayKeysProvider);
    final reasons = ref.watch(blockedReasonsProvider);
    final busy = ref.watch(busySlotsProvider).value ?? const <AppointmentEntry>[];

    final warnings = evaluateSchedule(
      at: draft.at,
      durationMinutes: draft.durationMinutes,
      hours: hours,
      blockedDays: blocked,
      blockedReasons: reasons,
      existing: busy.map((e) => e.appointment.busySlot),
      excludeId: excludeId,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickDate(context, ref),
                icon: const Icon(Icons.calendar_today_outlined, size: 18),
                label: Text(formats.weekdayDayMonth(draft.at)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickTime(context),
                icon: const Icon(Icons.schedule_outlined, size: 18),
                label: Text(formats.time(draft.at)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              strings.duration,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Wrap(
                spacing: 8,
                children: [
                  for (final minutes in const [15, 30, 45, 60])
                    ChoiceChip(
                      label: Text(strings.minutesShort(minutes)),
                      selected: draft.durationMinutes == minutes,
                      onSelected: (_) =>
                          onChanged(draft.copy()..durationMinutes = minutes),
                    ),
                ],
              ),
            ),
          ],
        ),
        ScheduleWarnings(warnings: warnings, strings: strings),
        const SizedBox(height: 4),
        ReminderSummary(
          rules: draft.rules,
          onChanged: (rules) => onChanged(draft.copy()..rules = rules),
        ),
      ],
    );
  }

  Future<void> _pickDate(BuildContext context, WidgetRef ref) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.at,
      firstDate: shopDateTime(shopNow().year - 1, 1, 1),
      lastDate: shopDateTime(shopNow().year + 3, 12, 31),
    );
    if (picked == null) return;
    onChanged(
      draft.copy()
        ..at = shopDateTime(
          picked.year,
          picked.month,
          picked.day,
          draft.at.hour,
          draft.at.minute,
        ),
    );
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: draft.at.hour, minute: draft.at.minute),
    );
    if (picked == null) return;
    onChanged(
      draft.copy()
        ..at = shopDateTime(
          draft.at.year,
          draft.at.month,
          draft.at.day,
          picked.hour,
          picked.minute,
        ),
    );
  }
}

class _CustomerSuggestions extends StatelessWidget {
  const _CustomerSuggestions({
    required this.customers,
    required this.query,
    required this.onPick,
  });

  final List<Customer> customers;
  final String query;
  final void Function(Customer) onPick;

  @override
  Widget build(BuildContext context) {
    final needle = query.trim().toLowerCase();
    if (needle.length < 2) return const SizedBox.shrink();
    final matches = customers
        .where(
          (c) =>
              c.name.toLowerCase().contains(needle) ||
              (c.phone ?? '').contains(needle),
        )
        .take(4)
        .toList();
    if (matches.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      children: [
        for (final customer in matches)
          ActionChip(
            avatar: const Icon(Icons.history, size: 16),
            label: Text(customer.name),
            onPressed: () => onPick(customer),
          ),
      ],
    );
  }
}

class _UnmatchedChip extends StatelessWidget {
  const _UnmatchedChip({
    required this.label,
    required this.value,
    required this.help,
  });

  final String label;
  final String value;
  final String help;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: help,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(Icons.help_outline, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '“$value”',
                style: theme.textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(label, style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

/// What the parser read, and what it could not — shown at the top of an import
/// so nothing silently disappears between WhatsApp and the form.
class _ImportSummary extends ConsumerWidget {
  const _ImportSummary({required this.parsed});

  final ParsedRequest parsed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final theme = Theme.of(context);
    final leftovers = parsed.unmatchedLines.where((l) => l.length > 2).toList();
    if (leftovers.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(strings.notUnderstood, style: theme.textTheme.labelLarge),
            ],
          ),
          const SizedBox(height: 6),
          for (final line in leftovers.take(4))
            Text(
              line,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}

class _RawMessageBlock extends StatelessWidget {
  const _RawMessageBlock({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: SelectableText(text, style: theme.textTheme.bodySmall),
    );
  }
}

/// Builds a draft from a parsed WhatsApp request. Name and phone are filled
/// when the message carries them (the website booking form does).
JobDraft draftFromParsed(
  ParsedRequest parsed, {
  required tz.TZDateTime fallbackAt,
  required int defaultDurationMinutes,
}) {
  final date = parsed.date;
  final time = parsed.time;
  final at = date == null
      ? fallbackAt
      : shopDateTime(
          date.year,
          date.month,
          date.day,
          time?.hour ?? fallbackAt.hour,
          time?.minute ?? fallbackAt.minute,
        );
  return JobDraft(
    customerName: parsed.customerName ?? '',
    phone: parsed.phone,
    service: parsed.service?.service,
    serviceFreeText: parsed.service?.matched == false
        ? parsed.service?.rawText
        : null,
    notes: parsed.notes,
    rawMessage: parsed.rawMessage,
    dropOff: AppointmentDraft(
      at: at,
      durationMinutes: defaultDurationMinutes,
    ),
  );
}
