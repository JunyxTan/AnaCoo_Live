import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../core/formatting.dart';
import '../../data/database.dart';
import '../../data/enums.dart';
import '../../data/extensions.dart';
import '../../domain/message_templates.dart';
import '../../domain/service_labels.dart';
import '../../domain/shop_time.dart';
import '../../domain/workflow_automation.dart';
import '../../l10n/app_strings.dart';
import '../../providers/providers.dart';
import '../../services/whatsapp_launcher.dart';
import '../widgets/common.dart';
import '../widgets/job_photos_section.dart';
import 'job_editor_screen.dart';

/// One job, top to bottom: who it is for, where it is in the pipeline, what the
/// work is, its two appointments, and the messages the tailor can send.
///
/// The reply buttons live in a bar pinned to the bottom rather than at the end
/// of the scroll, because sending "your item is ready" is the most common
/// reason to open this page at all.
class JobDetailScreen extends ConsumerWidget {
  const JobDetailScreen({super.key, required this.jobId});

  final int jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final bundle = ref.watch(jobBundleProvider(jobId));

    return Scaffold(
      appBar: AppBar(
        title: Text(bundle.value?.customer.name ?? strings.jobDetail),
        actions: [
          IconButton(
            tooltip: strings.edit,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _openEditor(context, jobId),
          ),
          PopupMenuButton<void>(
            tooltip: strings.delete,
            itemBuilder: (_) => [
              PopupMenuItem<void>(
                onTap: () => unawaited(_confirmDelete(context, ref, strings)),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.delete_outline),
                  title: Text(strings.delete),
                ),
              ),
            ],
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

void _openEditor(BuildContext context, int jobId) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => JobEditorScreen(jobId: jobId)),
  );
}

class _Body extends ConsumerWidget {
  const _Body({required this.bundle});

  final JobBundle bundle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final job = bundle.job;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _CustomerCard(bundle: bundle),
              const SizedBox(height: 12),
              _StatusCard(bundle: bundle),
              const SizedBox(height: 12),
              _WorkCard(bundle: bundle),
              const SizedBox(height: 12),
              JobPhotosSection(jobId: job.id),
              const SizedBox(height: 12),
              _AppointmentCard(
                appointment: bundle.dropOff,
                type: AppointmentType.dropOff,
                jobId: job.id,
              ),
              const SizedBox(height: 12),
              _AppointmentCard(
                appointment: bundle.collection,
                type: AppointmentType.collection,
                jobId: job.id,
              ),
              if (job.notes != null && job.notes!.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                SectionCard(
                  title: strings.notes,
                  icon: Icons.notes_outlined,
                  child: Text(job.notes!),
                ),
              ],
              if (job.rawMessage != null && job.rawMessage!.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                _RawMessageCard(text: job.rawMessage!),
              ],
            ],
          ),
        ),
        _MessageBar(bundle: bundle),
      ],
    );
  }
}

/// Name, number, and the two ways to reach the customer.
class _CustomerCard extends ConsumerWidget {
  const _CustomerCard({required this.bundle});

  final JobBundle bundle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final strings = ref.watch(appStringsProvider);
    final customer = bundle.customer;
    final phone = customer.phone ?? customer.whatsappNumber;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.onPrimaryContainer,
              child: Text(
                _initials(customer.name),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          customer.name,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (bundle.job.isRush) ...[
                        const SizedBox(width: 8),
                        const RushBadge(),
                      ],
                    ],
                  ),
                  if (phone != null && phone.trim().isNotEmpty)
                    Text(
                      WhatsAppLauncher.formatForDisplay(phone) ?? phone,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            if (phone != null && phone.trim().isNotEmpty) ...[
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: strings.call,
                onPressed: () => unawaited(_call(context, ref, phone, strings)),
                icon: const Icon(Icons.call_outlined),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _call(
    BuildContext context,
    WidgetRef ref,
    String phone,
    AppStrings strings,
  ) async {
    final ok = await ref.read(whatsAppLauncherProvider).call(phone);
    if (ok || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(strings.couldNotCall)),
    );
  }
}

String _initials(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  if (words.isEmpty) return '?';
  final letters = words.take(2).map((w) => w.substring(0, 1));
  return letters.join().toUpperCase();
}

/// Where the job is in the pipeline, with the one-tap way to move it on.
class _StatusCard extends ConsumerWidget {
  const _StatusCard({required this.bundle});

  final JobBundle bundle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final language = ref.watch(languageCodeProvider);
    final job = bundle.job;
    final next = job.status.next;

    return SectionCard(
      title: strings.status,
      icon: Icons.timeline_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StatusStepper(
            status: job.status,
            languageCode: language,
            onChanged: (status) => unawaited(
              applyJobStatusChange(context, ref, bundle: bundle, status: status),
            ),
          ),
          if (next != null) ...[
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: () =>
                  unawaited(ref.read(jobRepositoryProvider).advance(job.id)),
              icon: const Icon(Icons.arrow_forward),
              label: Text(
                '${strings.nextAction} · ${jobStatusLabel(next, language)}',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The service, the garment, and the money — the figures as tiles so they can
/// be read without tracing a label across the page.
class _WorkCard extends ConsumerWidget {
  const _WorkCard({required this.bundle});

  final JobBundle bundle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final strings = ref.watch(appStringsProvider);
    final language = ref.watch(languageCodeProvider);
    final formats = Formats(language);
    final job = bundle.job;
    final deposit = job.depositPaid;
    final hasDeposit = deposit != null && deposit > 0;
    final balance = job.quotedPrice == null ? null : job.quotedPrice! - (deposit ?? 0);

    return SectionCard(
      title: strings.service,
      icon: Icons.design_services_outlined,
      trailing: SectionAction(
        icon: Icons.edit_outlined,
        tooltip: strings.edit,
        onPressed: () => _openEditor(context, job.id),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            serviceLabel(job.service, language, freeText: job.serviceFreeText),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (job.itemDescription != null &&
              job.itemDescription!.trim().isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              job.itemDescription!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _Figure(
                  label: strings.quantity,
                  value: '${job.quantity}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Figure(
                  label: strings.quotedPrice,
                  value: formats.moneyShort(job.quotedPrice),
                ),
              ),
              if (hasDeposit) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: _Figure(
                    label: strings.depositPaid,
                    value: formats.moneyShort(deposit),
                  ),
                ),
              ],
            ],
          ),
          if (hasDeposit && balance != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  strings.balanceDue,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Text(
                  formats.money(balance),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// A drop-off or collection: a calendar block, the time, and one status pill
/// that opens a picker — rather than five chips competing for the same tap.
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
    final theme = Theme.of(context);
    final strings = ref.watch(appStringsProvider);
    final language = ref.watch(languageCodeProvider);
    final formats = Formats(language);
    final isDropOff = type == AppointmentType.dropOff;
    final title = isDropOff ? strings.dropOff : strings.collection;
    final icon =
        isDropOff ? Icons.download_outlined : Icons.upload_outlined;

    final a = appointment;
    if (a == null) {
      return SectionCard(
        title: title,
        icon: icon,
        child: Row(
          children: [
            Expanded(
              child: Text(
                strings.notScheduled,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.tonalIcon(
              onPressed: () => _openEditor(context, jobId),
              icon: const Icon(Icons.add),
              label: Text(strings.addCollection),
            ),
          ],
        ),
      );
    }

    final at = a.at;
    final isLate = a.status.isLive && at.isBefore(shopNow());
    final statusColor = appointmentStatusColor(theme.colorScheme, a.status);

    return SectionCard(
      title: title,
      icon: icon,
      trailing: SectionAction(
        icon: Icons.edit_calendar_outlined,
        tooltip: strings.edit,
        onPressed: () => _openEditor(context, jobId),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _DateBlock(at: at, formats: formats),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formats.relativeDate(
                        at,
                        todayLabel: strings.today,
                        tomorrowLabel: strings.tomorrow,
                      ),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${formats.time(at)} · ${strings.minutesShort(a.durationMinutes)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isLate) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.warning_amber_outlined,
                  size: 16,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(width: 6),
                Text(
                  strings.overdue,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: TintedPill(
              label: appointmentStatusLabel(a.status, language),
              icon: appointmentStatusIcon(a.status),
              color: statusColor,
              onTap: () => unawaited(_pickStatus(context, ref, a.status)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickStatus(
    BuildContext context,
    WidgetRef ref,
    AppointmentStatus current,
  ) async {
    final strings = ref.read(appStringsProvider);
    final language = ref.read(languageCodeProvider);
    final choice = await showModalBottomSheet<AppointmentStatus>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final status in AppointmentStatus.values)
              ListTile(
                leading: Icon(
                  appointmentStatusIcon(status),
                  color: appointmentStatusColor(
                    Theme.of(context).colorScheme,
                    status,
                  ),
                ),
                title: Text(appointmentStatusLabel(status, language)),
                trailing: status == current
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () => Navigator.of(context).pop(status),
              ),
          ],
        ),
      ),
    );
    if (choice == null || choice == current) return;
    await ref
        .read(jobRepositoryProvider)
        .setAppointmentStatus(jobId, type, choice);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${appointmentTypeLabel(type, language)} · '
          '${appointmentStatusLabel(choice, language)}',
        ),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: strings.undo,
          onPressed: () => unawaited(
            ref
                .read(jobRepositoryProvider)
                .setAppointmentStatus(jobId, type, current),
          ),
        ),
      ),
    );
  }
}

/// A calendar-page style date, so the day is legible at arm's length.
class _DateBlock extends StatelessWidget {
  const _DateBlock({required this.at, required this.formats});

  final tz.TZDateTime at;
  final Formats formats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 56,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            formats.weekdayNarrow(at.weekday).toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            '${at.day}',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _RawMessageCard extends ConsumerWidget {
  const _RawMessageCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final strings = ref.watch(appStringsProvider);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: Icon(
          Icons.chat_outlined,
          size: 18,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        title: Text(
          strings.rawMessage.toUpperCase(),
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SelectableText(
              text,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// The WhatsApp replies, pinned above the bottom edge so they stay in reach
/// however far the page has been scrolled.
class _MessageBar extends ConsumerWidget {
  const _MessageBar({required this.bundle});

  final JobBundle bundle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final strings = ref.watch(appStringsProvider);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    strings.whatsapp.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  for (final kind in TemplateKind.values) ...[
                    Expanded(
                      child: _MessageButton(
                        kind: kind,
                        label: switch (kind) {
                          TemplateKind.confirm => strings.whatsappConfirm,
                          TemplateKind.ready => strings.whatsappReady,
                          TemplateKind.reschedule => strings.whatsappReschedule,
                        },
                        onPressed: () => unawaited(_send(context, ref, kind)),
                      ),
                    ),
                    if (kind != TemplateKind.values.last)
                      const SizedBox(width: 8),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
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

class _MessageButton extends StatelessWidget {
  const _MessageButton({
    required this.kind,
    required this.label,
    required this.onPressed,
  });

  final TemplateKind kind;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final icon = switch (kind) {
      TemplateKind.confirm => Icons.check_circle_outline,
      TemplateKind.ready => Icons.inventory_2_outlined,
      TemplateKind.reschedule => Icons.event_repeat_outlined,
    };
    return FilledButton.tonal(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 8),
        minimumSize: const Size(0, 56),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

/// Applies a stepper change.
Future<void> applyJobStatusChange(
  BuildContext context,
  WidgetRef ref, {
  required JobBundle bundle,
  required JobStatus status,
}) async {
  final repo = ref.read(jobRepositoryProvider);
  await repo.setStatus(bundle.job.id, status);
}

/// Advances job status after a successful WhatsApp send.
Future<void> syncAfterWhatsAppAction(
  BuildContext context,
  WidgetRef ref, {
  required JobBundle bundle,
  required TemplateKind kind,
}) async {
  final repo = ref.read(jobRepositoryProvider);
  final next = statusAfterWhatsAppAction(bundle.job.status, kind);
  if (kind == TemplateKind.confirm) {
    await repo.confirmDropOffIfPending(bundle.job.id);
  }
  if (next != null) {
    await repo.setStatus(bundle.job.id, next);
  }
}

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
