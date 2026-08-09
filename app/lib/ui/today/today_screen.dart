import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting.dart';
import '../../data/database.dart';
import '../../data/enums.dart';
import '../../data/extensions.dart';
import '../../domain/service_labels.dart';
import '../../domain/shop_time.dart';
import '../../providers/providers.dart';
import '../job/job_detail_screen.dart';
import '../widgets/common.dart';

/// The home screen: what needs doing today, and the two ways to add work.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({
    super.key,
    required this.onPasteAppointment,
    required this.onNewJob,
  });

  final VoidCallback onPasteAppointment;
  final VoidCallback onNewJob;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final language = ref.watch(languageCodeProvider);
    final formats = Formats(language);

    final today = ref.watch(todayAppointmentsProvider).value ?? const [];
    final overdue = ref.watch(overdueAppointmentsProvider).value ?? const [];
    final ready = ref.watch(readyJobsProvider).value ?? const [];

    final dropOffs = today
        .where((e) => e.appointment.type == AppointmentType.dropOff)
        .toList();
    final collections = today
        .where((e) => e.appointment.type == AppointmentType.collection)
        .toList();
    // Overdue items are surfaced in their own section, not duplicated in the
    // day's lists.
    final overdueIds = overdue.map((e) => e.appointment.id).toSet();

    final isQuiet =
        today.isEmpty && overdue.isEmpty && ready.isEmpty;

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
                  onPressed: onPasteAppointment,
                  icon: const Icon(Icons.content_paste_go),
                  label: Text(strings.pasteAppointment),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onNewJob,
                  icon: const Icon(Icons.add),
                  label: Text(strings.newJob),
                ),
              ),
            ],
          ),
          if (isQuiet)
            EmptyState(message: strings.nothingToday, icon: Icons.wb_sunny_outlined),
          if (overdue.isNotEmpty) ...[
            SectionHeader(
              strings.overdue,
              count: overdue.length,
              icon: Icons.warning_amber_outlined,
            ),
            for (final entry in overdue)
              _Tile(entry: entry, language: language, showDate: true),
          ],
          if (dropOffs.isNotEmpty) ...[
            SectionHeader(
              strings.dropOffsToday,
              count: dropOffs.length,
              icon: Icons.download_outlined,
            ),
            for (final entry in dropOffs)
              if (!overdueIds.contains(entry.appointment.id))
                _Tile(entry: entry, language: language),
          ],
          if (collections.isNotEmpty) ...[
            SectionHeader(
              strings.collectionsDueToday,
              count: collections.length,
              icon: Icons.upload_outlined,
            ),
            for (final entry in collections)
              if (!overdueIds.contains(entry.appointment.id))
                _Tile(entry: entry, language: language),
          ],
          if (ready.isNotEmpty) ...[
            SectionHeader(
              strings.readyForPickup,
              count: ready.length,
              icon: Icons.inventory_2_outlined,
            ),
            for (final bundle in ready)
              _ReadyTile(bundle: bundle, language: language),
          ],
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.entry,
    required this.language,
    this.showDate = false,
  });

  final AppointmentEntry entry;
  final String language;
  final bool showDate;

  @override
  Widget build(BuildContext context) => AppointmentTile(
        entry: entry,
        languageCode: language,
        showDate: showDate,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => JobDetailScreen(jobId: entry.job.id),
          ),
        ),
      );
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

    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: const CircleAvatar(child: Icon(Icons.inventory_2_outlined, size: 20)),
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
      trailing: Column(
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
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => JobDetailScreen(jobId: bundle.job.id),
        ),
      ),
    );
  }
}
