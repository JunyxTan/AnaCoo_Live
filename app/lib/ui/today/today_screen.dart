import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting.dart';
import '../../data/database.dart';
import '../../domain/appointment_list_query.dart';
import '../../domain/shop_time.dart';
import '../../domain/workflow_automation.dart';
import '../../l10n/app_strings.dart';
import '../../providers/providers.dart';
import '../job/job_detail_screen.dart';
import '../widgets/common.dart';

/// Home: upcoming appointments (past kept in DB as history; Overdue filter
/// surfaces late live items).
class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({
    super.key,
    required this.onPasteAppointment,
    required this.onNewJob,
  });

  final VoidCallback onPasteAppointment;
  final VoidCallback onNewJob;

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  AppointmentFilter _filter = AppointmentFilter.all;
  AppointmentSort _sort = AppointmentSort.timeAsc;

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);
    final language = ref.watch(languageCodeProvider);
    final formats = Formats(language);

    final appointments =
        ref.watch(allAppointmentsProvider).value ?? const <AppointmentEntry>[];
    final nowUtc = DateTime.now().toUtc();
    final items = buildAppointmentItems(
      entries: appointments,
      filter: _filter,
      sort: _sort,
      nowUtc: nowUtc,
      hideHistory: true,
    );
    final hasActive = appointments.any(
      (entry) => !isAppointmentPast(entry, nowUtc),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.appTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Text(
                formats.fullDate(shopNow()),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: widget.onPasteAppointment,
                  icon: const Icon(Icons.content_paste_go),
                  label: Text(strings.pasteAppointment),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onNewJob,
                  icon: const Icon(Icons.add),
                  label: Text(strings.newJob),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => unawaited(_pickFilter(strings)),
                  icon: Icon(
                    _filter == AppointmentFilter.all
                        ? Icons.filter_list_outlined
                        : Icons.filter_alt,
                  ),
                  label: Text(
                    _filter == AppointmentFilter.all
                        ? strings.filter
                        : strings.appointmentFilterLabel(_filter),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => unawaited(_pickSort(strings)),
                  icon: const Icon(Icons.sort),
                  label: Text(
                    _sort == AppointmentSort.timeAsc
                        ? strings.sort
                        : strings.appointmentSortLabel(_sort),
                  ),
                ),
              ),
            ],
          ),
          if (items.isEmpty)
            EmptyState(
              message: hasActive
                  ? strings.noMatchingAppointments
                  : strings.noAppointments,
              icon: hasActive
                  ? Icons.search_off_outlined
                  : Icons.event_note_outlined,
            )
          else ...[
            SectionHeader(
              strings.appointments,
              count: items.length,
              icon: Icons.event_note_outlined,
            ),
            for (final entry in items)
              _Tile(
                entry: entry,
                language: language,
                showDate: true,
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickFilter(AppStrings strings) async {
    final choice = await showModalBottomSheet<AppointmentFilter>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final filter in allAppointmentFilters)
              ListTile(
                leading: Icon(_filterIcon(filter)),
                title: Text(strings.appointmentFilterLabel(filter)),
                trailing: filter == _filter
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () => Navigator.of(context).pop(filter),
              ),
          ],
        ),
      ),
    );
    if (choice == null || !mounted) return;
    setState(() => _filter = choice);
  }

  Future<void> _pickSort(AppStrings strings) async {
    final choice = await showModalBottomSheet<AppointmentSort>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final sort in AppointmentSort.values)
              ListTile(
                leading: Icon(_sortIcon(sort)),
                title: Text(strings.appointmentSortLabel(sort)),
                trailing: sort == _sort
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () => Navigator.of(context).pop(sort),
              ),
          ],
        ),
      ),
    );
    if (choice == null || !mounted) return;
    setState(() => _sort = choice);
  }
}

IconData _filterIcon(AppointmentFilter filter) => switch (filter) {
      AppointmentFilter.all => Icons.list_alt_outlined,
      AppointmentFilter.dropOff => Icons.download_outlined,
      AppointmentFilter.collection => Icons.upload_outlined,
      AppointmentFilter.overdue => Icons.warning_amber_outlined,
      AppointmentFilter.ready => Icons.inventory_2_outlined,
      AppointmentFilter.rush => Icons.bolt_outlined,
    };

IconData _sortIcon(AppointmentSort sort) => switch (sort) {
      AppointmentSort.timeAsc => Icons.arrow_upward,
      AppointmentSort.timeDesc => Icons.arrow_downward,
      AppointmentSort.name => Icons.sort_by_alpha,
      AppointmentSort.rushFirst => Icons.bolt_outlined,
    };

class _Tile extends ConsumerWidget {
  const _Tile({
    required this.entry,
    required this.language,
    this.showDate = false,
  });

  final AppointmentEntry entry;
  final String language;
  final bool showDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final next = nextStatusFor(entry.job.status);
    return AppointmentTile(
      entry: entry,
      languageCode: language,
      showDate: showDate,
      actionLabel: next == null ? null : strings.nextAction,
      onAction: next == null
          ? null
          : () => unawaited(_advance(context, ref, entry.job.id)),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => JobDetailScreen(jobId: entry.job.id),
        ),
      ),
    );
  }
}

Future<void> _advance(BuildContext context, WidgetRef ref, int jobId) async {
  final repo = ref.read(jobRepositoryProvider);
  await repo.advance(
    jobId,
    hours: ref.read(workingHoursProvider),
    turnaroundDays: ref.read(turnaroundDaysProvider),
    slotMinutes: ref.read(slotMinutesProvider),
  );
}
