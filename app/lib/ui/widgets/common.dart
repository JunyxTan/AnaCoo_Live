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
          // Title takes what is left after the trailing control, so a language
          // dropdown cannot shove "Language" off a narrow phone.
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
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
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// A titled block of content in a bordered card.
///
/// The job page is read at a glance between customers, so related facts are
/// grouped into a handful of cards instead of one long ribbon of rows.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.count,
    this.trailing,
  });

  final String title;
  final Widget child;
  final IconData? icon;
  final int? count;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 12, trailing == null ? 16 : 8, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                ],
                Text(
                  title.toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                if (count != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text('$count', style: theme.textTheme.labelSmall),
                  ),
                ],
                const Spacer(),
                ?trailing,
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

/// A compact icon action for the header of a [SectionCard].
class SectionAction extends StatelessWidget {
  const SectionAction({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 40, height: 40),
        style: IconButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
}

/// The chrome for the buttons pinned below a screen's scrolling content: a
/// shaded strip with a top edge, held clear of the system inset.
///
/// The buttons live down here because that is where the hand already is. It
/// also means a long list cannot scroll them out of reach.
///
/// One widget serves both hosts: inside the tab shell the navigation bar
/// answers for the bottom inset — and `Scaffold` zeroes the padding it hands
/// its body when it has one — so the [SafeArea] adds nothing there and lifts
/// the bar clear of the home indicator on a pushed route.
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
          child: child,
        ),
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

/// One appointment row: who, what, when, and an optional primary action.
class AppointmentTile extends StatelessWidget {
  const AppointmentTile({
    super.key,
    required this.entry,
    required this.languageCode,
    this.onTap,
    this.showDate = false,
    this.actionLabel,
    this.onAction,
  });

  final AppointmentEntry entry;
  final String languageCode;
  final VoidCallback? onTap;
  final bool showDate;
  final String? actionLabel;
  final VoidCallback? onAction;

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
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
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
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(width: 8),
            FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                minimumSize: const Size(56, 36),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                visualDensity: VisualDensity.compact,
              ),
              child: Text(actionLabel!),
            ),
          ],
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

IconData appointmentStatusIcon(AppointmentStatus status) => switch (status) {
      AppointmentStatus.pending => Icons.hourglass_empty,
      AppointmentStatus.confirmed => Icons.check,
      AppointmentStatus.done => Icons.done_all,
      AppointmentStatus.noShow => Icons.person_off_outlined,
      AppointmentStatus.cancelled => Icons.close,
    };

/// The accent an appointment status is drawn in: neutral while pending, the
/// brand colour once confirmed, green when done, red when it fell through.
Color appointmentStatusColor(ColorScheme scheme, AppointmentStatus status) =>
    switch (status) {
      AppointmentStatus.pending => scheme.onSurfaceVariant,
      AppointmentStatus.confirmed => scheme.primary,
      AppointmentStatus.done => scheme.tertiary,
      AppointmentStatus.noShow || AppointmentStatus.cancelled => scheme.error,
    };

/// A tinted label pill. With [onTap] it reads as a button that opens a picker.
class TintedPill extends StatelessWidget {
  const TintedPill({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.onTap,
  });

  final String label;
  final Color color;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: color.withValues(alpha: 0.14),
      shape: StadiumBorder(
        side: BorderSide(color: color.withValues(alpha: 0.45)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 15, color: color),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 2),
                Icon(Icons.expand_more, size: 16, color: color),
              ],
            ],
          ),
        ),
      ),
    );
  }
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

/// The job pipeline as a tappable stepper: every step keeps its label, so the
/// tailor can see where the job is and where it is going without tapping.
class StatusStepper extends StatelessWidget {
  const StatusStepper({
    super.key,
    required this.status,
    required this.languageCode,
    required this.onChanged,
    this.dates = const {},
  });

  final JobStatus status;
  final String languageCode;
  final ValueChanged<JobStatus> onChanged;

  /// Preformatted date to print above a step, for the steps that have one.
  /// The row of them reads left to right as the job's timeline.
  final Map<JobStatus, String> dates;

  static IconData iconFor(JobStatus status) => switch (status) {
        JobStatus.booked => Icons.event_available_outlined,
        JobStatus.received => Icons.move_to_inbox_outlined,
        JobStatus.sewing => Icons.content_cut,
        JobStatus.ready => Icons.inventory_2_outlined,
        JobStatus.done => Icons.done_all,
        JobStatus.cancelled => Icons.block,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (status.isCancelled) {
      final color = theme.colorScheme.error;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Icon(Icons.block, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              jobStatusLabel(status, languageCode),
              style: theme.textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }
    return Row(
      children: [
        for (var i = 0; i < JobStatus.pipeline.length; i++)
          Expanded(
            child: _Step(
              icon: iconFor(JobStatus.pipeline[i]),
              label: jobStatusLabel(JobStatus.pipeline[i], languageCode),
              date: dates[JobStatus.pipeline[i]],
              reached: i <= status.step,
              current: i == status.step,
              lineBefore: i == 0 ? null : i <= status.step,
              lineAfter:
                  i == JobStatus.pipeline.length - 1 ? null : i < status.step,
              onTap: () => onChanged(JobStatus.pipeline[i]),
            ),
          ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.icon,
    required this.label,
    required this.date,
    required this.reached,
    required this.current,
    required this.lineBefore,
    required this.lineAfter,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String? date;
  final bool reached;
  final bool current;

  /// Whether the connector on that side is drawn, and whether it is already
  /// travelled. Null means there is no neighbour on that side.
  final bool? lineBefore;
  final bool? lineAfter;

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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            // Kept at a fixed height whether or not this step has a date, so
            // the circles stay on one line.
            SizedBox(
              height: 16,
              child: Text(
                date ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: current
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: current ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(child: _Connector(travelled: lineBefore)),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: background,
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: Icon(icon, size: 20, color: foreground)),
                ),
                Expanded(child: _Connector(travelled: lineAfter)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: current
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: current ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Connector extends StatelessWidget {
  const _Connector({required this.travelled});

  final bool? travelled;

  @override
  Widget build(BuildContext context) {
    if (travelled == null) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 2,
      color: travelled!
          ? scheme.primary
          // The outline colours are too close to the card in the dark theme to
          // read as a track, so the untravelled leg is a faded foreground.
          : scheme.onSurfaceVariant.withValues(alpha: 0.3),
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
