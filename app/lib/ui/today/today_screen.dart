import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting.dart';
import '../../data/database.dart';
import '../../data/extensions.dart';
import '../../domain/service_labels.dart';
import '../../domain/shop_time.dart';
import '../../domain/today_list.dart';
import '../../domain/workflow_automation.dart';
import '../../l10n/app_strings.dart';
import '../../providers/providers.dart';
import '../job/job_detail_screen.dart';
import '../widgets/common.dart';

/// Home: today's appointments as one filterable, sortable list.
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
  TodayFilter _filter = TodayFilter.all;
  TodaySort _sort = TodaySort.timeAsc;

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);
    final language = ref.watch(languageCodeProvider);
    final formats = Formats(language);

    final today = ref.watch(todayAppointmentsProvider).value ?? const [];
    final overdue = ref.watch(overdueAppointmentsProvider).value ?? const [];
    final ready = ref.watch(readyJobsProvider).value ?? const [];

    final items = buildTodayItems(
      today: today,
      overdue: overdue,
      ready: ready,
      filter: _filter,
      sort: _sort,
    );
    final hasAny = today.isNotEmpty || overdue.isNotEmpty || ready.isNotEmpty;

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
                    _filter == TodayFilter.all
                        ? Icons.filter_list_outlined
                        : Icons.filter_alt,
                  ),
                  label: Text(
                    _filter == TodayFilter.all
                        ? strings.filter
                        : _filterLabel(strings, _filter),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => unawaited(_pickSort(strings)),
                  icon: const Icon(Icons.sort),
                  label: Text(
                    _sort == TodaySort.timeAsc
                        ? strings.sort
                        : _sortLabel(strings, _sort),
                  ),
                ),
              ),
            ],
          ),
          if (items.isEmpty)
            EmptyState(
              message: hasAny
                  ? strings.noMatchingAppointments
                  : strings.nothingToday,
              icon: hasAny
                  ? Icons.search_off_outlined
                  : Icons.wb_sunny_outlined,
            )
          else ...[
            SectionHeader(
              strings.tabToday,
              count: items.length,
              icon: Icons.wb_sunny_outlined,
            ),
            for (final item in items)
              switch (item) {
                TodayAppointmentItem(:final entry, :final isOverdue) => _Tile(
                    entry: entry,
                    language: language,
                    showDate: isOverdue,
                  ),
                TodayReadyItem(:final bundle) => _ReadyTile(
                    bundle: bundle,
                    language: language,
                  ),
              },
          ],
        ],
      ),
    );
  }

  Future<void> _pickFilter(AppStrings strings) async {
    final choice = await showModalBottomSheet<TodayFilter>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final filter in TodayFilter.values)
              ListTile(
                leading: Icon(_filterIcon(filter)),
                title: Text(_filterLabel(strings, filter)),
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
    final choice = await showModalBottomSheet<TodaySort>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final sort in TodaySort.values)
              ListTile(
                leading: Icon(_sortIcon(sort)),
                title: Text(_sortLabel(strings, sort)),
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

String _filterLabel(AppStrings strings, TodayFilter filter) => switch (filter) {
      TodayFilter.all => strings.filterAll,
      TodayFilter.dropOff => strings.dropOffsToday,
      TodayFilter.collection => strings.collectionsDueToday,
      TodayFilter.overdue => strings.overdue,
      TodayFilter.ready => strings.readyForPickup,
      TodayFilter.rush => strings.filterRush,
    };

String _sortLabel(AppStrings strings, TodaySort sort) => switch (sort) {
      TodaySort.timeAsc => strings.sortTimeAsc,
      TodaySort.timeDesc => strings.sortTimeDesc,
      TodaySort.name => strings.sortName,
      TodaySort.rushFirst => strings.sortRushFirst,
    };

IconData _filterIcon(TodayFilter filter) => switch (filter) {
      TodayFilter.all => Icons.list_alt_outlined,
      TodayFilter.dropOff => Icons.download_outlined,
      TodayFilter.collection => Icons.upload_outlined,
      TodayFilter.overdue => Icons.warning_amber_outlined,
      TodayFilter.ready => Icons.inventory_2_outlined,
      TodayFilter.rush => Icons.bolt_outlined,
    };

IconData _sortIcon(TodaySort sort) => switch (sort) {
      TodaySort.timeAsc => Icons.arrow_upward,
      TodaySort.timeDesc => Icons.arrow_downward,
      TodaySort.name => Icons.sort_by_alpha,
      TodaySort.rushFirst => Icons.bolt_outlined,
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

class _ReadyTile extends ConsumerWidget {
  const _ReadyTile({required this.bundle, required this.language});

  final JobBundle bundle;
  final String language;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final formats = Formats(language);
    final readyAt = bundle.job.readyAt;
    final waitingDays = readyAt == null
        ? 0
        : startOfDay(shopNow()).difference(startOfDay(toShop(readyAt))).inDays;
    final next = nextStatusFor(bundle.job.status);

    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading:
          const CircleAvatar(child: Icon(Icons.inventory_2_outlined, size: 20)),
      title: Text(
        bundle.customer.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        serviceLabel(
          bundle.job.service,
          language,
          freeText: bundle.job.serviceFreeText,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (waitingDays > 0)
                Text(
                  strings.days(waitingDays),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              if (bundle.collection != null)
                Text(
                  formats.dayMonth(bundle.collection!.at),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
            ],
          ),
          if (next != null) ...[
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () => unawaited(_advance(context, ref, bundle.job.id)),
              style: FilledButton.styleFrom(
                minimumSize: const Size(56, 36),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                visualDensity: VisualDensity.compact,
              ),
              child: Text(strings.nextAction),
            ),
          ],
        ],
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => JobDetailScreen(jobId: bundle.job.id),
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
