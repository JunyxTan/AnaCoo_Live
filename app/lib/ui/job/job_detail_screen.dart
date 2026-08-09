import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../core/formatting.dart';
import '../../data/database.dart';
import '../../data/enums.dart';
import '../../data/extensions.dart';
import '../../data/job_repository.dart';
import '../../domain/message_templates.dart';
import '../../domain/scheduling.dart';
import '../../domain/service_labels.dart';
import '../../domain/shop_time.dart';
import '../../domain/workflow_automation.dart';
import '../../l10n/app_strings.dart';
import '../../providers/providers.dart';
import '../widgets/common.dart';
import 'job_editor_screen.dart';

class JobDetailScreen extends ConsumerWidget {
  const JobDetailScreen({super.key, required this.jobId});

  final int jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final bundle = ref.watch(jobBundleProvider(jobId));

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.jobDetail),
        actions: [
          IconButton(
            tooltip: strings.edit,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => JobEditorScreen(jobId: jobId),
              ),
            ),
          ),
          IconButton(
            tooltip: strings.delete,
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, ref, strings),
          ),
        ],
      ),
      body: bundle.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (data) => data == null
            ? Center(child: Text(strings.jobDetail))
            : _Body(bundle: data),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
  ) async {
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
    if (confirmed != true || !context.mounted) return;
    await ref.read(jobRepositoryProvider).deleteJob(jobId);
    if (context.mounted) Navigator.of(context).pop();
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.bundle});

  final JobBundle bundle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final language = ref.watch(languageCodeProvider);
    final formats = Formats(language);
    final job = bundle.job;
    final customer = bundle.customer;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                customer.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            if (job.isRush) const RushBadge(),
          ],
        ),
        if (customer.phone != null)
          Text(
            customer.phone!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        const SizedBox(height: 20),
        StatusStepper(
          status: job.status,
          languageCode: language,
          onChanged: (status) => unawaited(
            applyJobStatusChange(context, ref, bundle: bundle, status: status),
          ),
        ),
        SectionHeader(strings.service, icon: Icons.design_services_outlined),
        DetailRow(
          label: strings.service,
          value: serviceLabel(job.service, language, freeText: job.serviceFreeText),
        ),
        DetailRow(
          label: strings.itemDescription,
          value: job.itemDescription ?? '—',
        ),
        DetailRow(label: strings.quantity, value: '${job.quantity}'),
        DetailRow(
          label: strings.quotedPrice,
          value: formats.money(job.quotedPrice),
        ),
        DetailRow(
          label: strings.depositPaid,
          value: formats.money(job.depositPaid),
        ),
        SectionHeader(strings.dropOff, icon: Icons.download_outlined),
        _AppointmentCard(
          appointment: bundle.dropOff,
          type: AppointmentType.dropOff,
          jobId: job.id,
        ),
        SectionHeader(strings.collection, icon: Icons.upload_outlined),
        _AppointmentCard(
          appointment: bundle.collection,
          type: AppointmentType.collection,
          jobId: job.id,
        ),
        if (job.notes != null) ...[
          SectionHeader(strings.notes, icon: Icons.notes_outlined),
          Text(job.notes!),
        ],
        if (job.rawMessage != null) ...[
          SectionHeader(strings.rawMessage, icon: Icons.chat_outlined),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: SelectableText(
              job.rawMessage!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
        const SizedBox(height: 24),
        _WhatsAppActions(bundle: bundle),
      ],
    );
  }
}

class _AppointmentCard extends ConsumerWidget {
  const _AppointmentCard({
    required this.appointment,
    required this.type,
    required this.jobId,
  });

  final Appointment? appointment;
  final AppointmentType type;
  final int jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final language = ref.watch(languageCodeProvider);
    final formats = Formats(language);

    if (appointment == null) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.event_busy_outlined),
          title: Text(strings.collectionNotSet),
          trailing: IconButton.filledTonal(
            tooltip: strings.addCollection,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => JobEditorScreen(jobId: jobId),
              ),
            ),
            icon: const Icon(Icons.add),
          ),
        ),
      );
    }

    final a = appointment!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  type == AppointmentType.dropOff
                      ? Icons.download_outlined
                      : Icons.upload_outlined,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  formats.fullDate(a.at),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(formats.time(a.at)),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                for (final status in AppointmentStatus.values)
                  ChoiceChip(
                    avatar: Icon(_appointmentStatusIcon(status), size: 16),
                    label: Text(appointmentStatusLabel(status, language)),
                    selected: a.status == status,
                    onSelected: (_) => ref
                        .read(jobRepositoryProvider)
                        .setAppointmentStatus(jobId, type, status),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

IconData _appointmentStatusIcon(AppointmentStatus status) => switch (status) {
      AppointmentStatus.pending => Icons.hourglass_empty,
      AppointmentStatus.confirmed => Icons.check,
      AppointmentStatus.done => Icons.done_all,
      AppointmentStatus.noShow => Icons.person_off_outlined,
      AppointmentStatus.cancelled => Icons.close,
    };

/// Confirm / Ready / Reschedule as a compact icon button row.
/// Confirm and Ready also advance the job pipeline so the tailor does not have
/// to tap the stepper separately.
class _WhatsAppActions extends ConsumerWidget {
  const _WhatsAppActions({required this.bundle});

  final JobBundle bundle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    return Row(
      children: [
        for (final kind in TemplateKind.values) ...[
          Expanded(
            child: OutlinedButton(
              onPressed: () => unawaited(_send(context, ref, kind)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    switch (kind) {
                      TemplateKind.confirm => Icons.check_circle_outline,
                      TemplateKind.ready => Icons.inventory_2_outlined,
                      TemplateKind.reschedule => Icons.event_repeat_outlined,
                    },
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    switch (kind) {
                      TemplateKind.confirm => strings.whatsappConfirm,
                      TemplateKind.ready => strings.whatsappReady,
                      TemplateKind.reschedule => strings.whatsappReschedule,
                    },
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ),
          if (kind != TemplateKind.values.last) const SizedBox(width: 8),
        ],
      ],
    );
  }

  Future<void> _send(
    BuildContext context,
    WidgetRef ref,
    TemplateKind kind,
  ) async {
    final strings = ref.read(appStringsProvider);
    final message = buildTemplateMessage(
      bundle: bundle,
      kind: kind,
      templates: ref.read(templatesProvider),
      languageCode: ref.read(languageCodeProvider),
    );
    final phone = bundle.customer.whatsappNumber ?? bundle.customer.phone;
    if (phone == null || phone.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.noWhatsappNumber)),
      );
      return;
    }
    final ok = await ref
        .read(whatsAppLauncherProvider)
        .send(phone: phone, message: message);
    if (!ok) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.couldNotOpenWhatsapp)),
        );
      }
      return;
    }
    if (!context.mounted) return;
    await syncAfterWhatsAppAction(context, ref, bundle: bundle, kind: kind);
  }
}

/// Applies a stepper change and, when landing on Ready without a collection,
/// offers to schedule one from the turnaround suggestion.
Future<void> applyJobStatusChange(
  BuildContext context,
  WidgetRef ref, {
  required JobBundle bundle,
  required JobStatus status,
}) async {
  await ref.read(jobRepositoryProvider).setStatus(bundle.job.id, status);
  if (!context.mounted) return;
  if (shouldPromptForCollection(
    status: status,
    collectionSet: bundle.collection != null,
  )) {
    await promptForCollection(context, ref, bundle: bundle);
  }
}

/// Advances job / drop-off status to match a successful WhatsApp send.
Future<void> syncAfterWhatsAppAction(
  BuildContext context,
  WidgetRef ref, {
  required JobBundle bundle,
  required TemplateKind kind,
}) async {
  final repo = ref.read(jobRepositoryProvider);
  final next = statusAfterWhatsAppAction(bundle.job.status, kind);
  if (next != null) {
    await repo.setStatus(bundle.job.id, next);
  }
  if (kind == TemplateKind.confirm) {
    await repo.confirmDropOffIfPending(bundle.job.id);
  }
  if (!context.mounted) return;
  if (kind == TemplateKind.ready && bundle.collection == null) {
    await promptForCollection(context, ref, bundle: bundle);
  }
}

/// Offers to book the missing collection at the turnaround suggestion.
Future<void> promptForCollection(
  BuildContext context,
  WidgetRef ref, {
  required JobBundle bundle,
}) async {
  if (bundle.collection != null) return;

  final strings = ref.read(appStringsProvider);
  final language = ref.read(languageCodeProvider);
  final formats = Formats(language);
  final hours = ref.read(workingHoursProvider);
  final slot = ref.read(slotMinutesProvider);
  final turnaround = ref.read(turnaroundDaysProvider);

  final tz.TZDateTime dropOffAt = bundle.dropOff?.at ?? shopNow();
  final suggested = suggestCollection(
    dropOffAt,
    hours,
    turnaroundDays: turnaround,
    slotMinutes: slot,
  );
  final when = '${formats.fullDate(suggested)} · ${formats.time(suggested)}';

  final choice = await showDialog<_CollectionPromptChoice>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.upload_outlined),
      title: Text(strings.scheduleCollectionTitle),
      content: Text(when),
      actions: [
        IconButton(
          tooltip: strings.notNow,
          onPressed: () =>
              Navigator.of(context).pop(_CollectionPromptChoice.notNow),
          icon: const Icon(Icons.close),
        ),
        TextButton.icon(
          onPressed: () =>
              Navigator.of(context).pop(_CollectionPromptChoice.pick),
          icon: const Icon(Icons.edit_calendar_outlined, size: 18),
          label: Text(strings.pickCollectionTime),
        ),
        FilledButton.icon(
          onPressed: () =>
              Navigator.of(context).pop(_CollectionPromptChoice.schedule),
          icon: const Icon(Icons.check, size: 18),
          label: Text(strings.scheduleSuggested),
        ),
      ],
    ),
  );
  if (choice == null || choice == _CollectionPromptChoice.notNow) return;
  if (!context.mounted) return;

  if (choice == _CollectionPromptChoice.schedule) {
    await ref.read(jobRepositoryProvider).scheduleCollection(
          bundle.job.id,
          AppointmentDraft(at: suggested),
        );
    return;
  }

  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => JobEditorScreen(
        jobId: bundle.job.id,
        seedCollectionAt: suggested,
      ),
    ),
  );
}

enum _CollectionPromptChoice { notNow, pick, schedule }

/// Fills a reply template from a job. Shared with the Settings preview.
String buildTemplateMessage({
  required JobBundle bundle,
  required TemplateKind kind,
  required MessageTemplates templates,
  required String languageCode,
}) {
  final formats = Formats(languageCode);
  final dropOff = bundle.dropOff;
  final collection = bundle.collection;
  return MessageTemplates.fill(
    templates.bodyFor(kind, languageCode),
    {
      'name': bundle.customer.name,
      'date': dropOff == null ? null : formats.fullDate(dropOff.at),
      'time': dropOff == null ? null : formats.time(dropOff.at),
      'service': serviceLabel(
        bundle.job.service,
        languageCode,
        freeText: bundle.job.serviceFreeText,
      ),
      'price': bundle.job.quotedPrice == null
          ? null
          : formats.money(bundle.job.quotedPrice),
      'collectDate':
          collection == null ? null : formats.fullDate(collection.at),
    },
  );
}
