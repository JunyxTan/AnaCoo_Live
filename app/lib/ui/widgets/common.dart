import 'package:flutter/material.dart';

import '../../core/formatting.dart';
import '../../core/theme.dart';
import '../../data/database.dart';
import '../../data/enums.dart';
import '../../data/extensions.dart';
import '../../domain/scheduling.dart';
import '../../domain/service_labels.dart';
import '../../l10n/app_strings.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader(
    this.title, {
    super.key,
    this.trailing,
    this.count,
    this.icon,
  });

  final String title;
  final Widget? trailing;
  final int? count;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text('$count', style: theme.textTheme.labelMedium),
            ),
          ],
          const Spacer(),
          ?trailing,
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.message, this.icon});

  final String message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 12),
      child: Column(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 32, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
          ],
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// One appointment row: who, what, when, and whether it needs attention.
class AppointmentTile extends StatelessWidget {
  const AppointmentTile({
    super.key,
    required this.entry,
    required this.languageCode,
    this.onTap,
    this.showDate = false,
  });

  final AppointmentEntry entry;
  final String languageCode;
  final VoidCallback? onTap;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formats = Formats(languageCode);
    final at = entry.appointment.at;
    final isDropOff = entry.appointment.type == AppointmentType.dropOff;

    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: CircleAvatar(
        backgroundColor: isDropOff
            ? theme.colorScheme.secondaryContainer
            : theme.colorScheme.primaryContainer,
        foregroundColor: isDropOff
            ? theme.colorScheme.onSecondaryContainer
            : theme.colorScheme.onPrimaryContainer,
        child: Icon(
          isDropOff ? Icons.download_outlined : Icons.upload_outlined,
          size: 20,
        ),
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              entry.customer.name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          if (entry.job.isRush) ...[
            const SizedBox(width: 6),
            const RushBadge(),
          ],
        ],
      ),
      subtitle: Text(
        '${serviceLabel(entry.job.service, languageCode, freeText: entry.job.serviceFreeText)}'
        '${entry.job.itemDescription == null ? '' : ' · ${entry.job.itemDescription}'}',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            formats.time(at),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (showDate)
            Text(
              formats.dayMonth(at),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}

class RushBadge extends StatelessWidget {
  const RushBadge({super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        decoration: BoxDecoration(
          color: AnacooTheme.rush.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AnacooTheme.rush.withValues(alpha: 0.5)),
        ),
        child: const Text(
          'RUSH',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: AnacooTheme.rush,
          ),
        ),
      );
}

/// Renders scheduling warnings inline. These never block a save — the tailor
/// knows their diary better than the app does.
class ScheduleWarnings extends StatelessWidget {
  const ScheduleWarnings({
    super.key,
    required this.warnings,
    required this.strings,
  });

  final List<ScheduleWarning> warnings;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    if (warnings.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final warning in warnings)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _label(warning),
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _label(ScheduleWarning warning) => switch (warning.kind) {
        ScheduleWarningKind.closedDay => strings.warningClosedDay,
        ScheduleWarningKind.outsideWorkingHours => strings.warningOutsideHours,
        ScheduleWarningKind.blockedDate => strings.warningBlocked(warning.reason),
        ScheduleWarningKind.clash => strings.warningClash(
            warning.clashCount,
            warning.clashType == AppointmentType.dropOff,
          ),
        ScheduleWarningKind.inThePast => strings.warningInThePast,
      };
}

/// The job pipeline as a tappable icon stepper.
class StatusStepper extends StatelessWidget {
  const StatusStepper({
    super.key,
    required this.status,
    required this.languageCode,
    required this.onChanged,
  });

  final JobStatus status;
  final String languageCode;
  final ValueChanged<JobStatus> onChanged;

  static IconData iconFor(JobStatus status) => switch (status) {
        JobStatus.requested => Icons.inbox_outlined,
        JobStatus.confirmed => Icons.check_circle_outline,
        JobStatus.received => Icons.download_outlined,
        JobStatus.inProgress => Icons.content_cut,
        JobStatus.ready => Icons.inventory_2_outlined,
        JobStatus.collected => Icons.done_all,
        JobStatus.cancelled => Icons.block,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (status.isCancelled) {
      return Chip(
        avatar: const Icon(Icons.block, size: 18),
        label: Text(jobStatusLabel(status, languageCode)),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < JobStatus.pipeline.length; i++) ...[
            if (i > 0)
              Container(
                width: 10,
                height: 1,
                color: theme.colorScheme.outlineVariant,
              ),
            _Step(
              icon: iconFor(JobStatus.pipeline[i]),
              label: jobStatusLabel(JobStatus.pipeline[i], languageCode),
              reached: i <= status.step,
              current: i == status.step,
              onTap: () => onChanged(JobStatus.pipeline[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.icon,
    required this.label,
    required this.reached,
    required this.current,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool reached;
  final bool current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = current
        ? theme.colorScheme.primary
        : reached
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHigh;
    final foreground = current
        ? theme.colorScheme.onPrimary
        : reached
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurfaceVariant;
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: foreground),
              if (current) ...[
                const SizedBox(width: 6),
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A labelled block in the job detail sheet.
class DetailRow extends StatelessWidget {
  const DetailRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
