import '../data/database.dart';
import 'appointment_list_query.dart';

export 'appointment_list_query.dart';

/// One row on the Today agenda after filter + sort.
sealed class TodayItem {
  const TodayItem();

  String get customerName;
  bool get isRush;
  DateTime get sortTime;
}

final class TodayAppointmentItem extends TodayItem {
  const TodayAppointmentItem({
    required this.entry,
    required this.isOverdue,
  });

  final AppointmentEntry entry;
  final bool isOverdue;

  @override
  String get customerName => entry.customer.name;

  @override
  bool get isRush => entry.job.isRush;

  @override
  DateTime get sortTime => appointmentSortTime(entry);
}

final class TodayReadyItem extends TodayItem {
  const TodayReadyItem(this.bundle);

  final JobBundle bundle;

  @override
  String get customerName => bundle.customer.name;

  @override
  bool get isRush => bundle.job.isRush;

  @override
  DateTime get sortTime =>
      bundle.collection?.scheduledAt ??
      bundle.job.readyAt ??
      bundle.job.createdAt;
}

/// Builds the filtered + sorted Today agenda from the three live feeds.
List<TodayItem> buildTodayItems({
  required List<AppointmentEntry> today,
  required List<AppointmentEntry> overdue,
  required List<JobBundle> ready,
  required AppointmentFilter filter,
  required AppointmentSort sort,
}) {
  final overdueIds = overdue.map((e) => e.appointment.id).toSet();
  final items = <TodayItem>[];

  for (final entry in overdue) {
    if (appointmentMatchesFilter(entry, filter, isOverdue: true)) {
      items.add(TodayAppointmentItem(entry: entry, isOverdue: true));
    }
  }

  for (final entry in today) {
    if (overdueIds.contains(entry.appointment.id)) continue;
    if (appointmentMatchesFilter(entry, filter)) {
      items.add(TodayAppointmentItem(entry: entry, isOverdue: false));
    }
  }

  final includeReady = switch (filter) {
    AppointmentFilter.all || AppointmentFilter.ready => true,
    AppointmentFilter.rush => true,
    AppointmentFilter.dropOff ||
    AppointmentFilter.collection ||
    AppointmentFilter.overdue =>
      false,
  };
  if (includeReady) {
    for (final bundle in ready) {
      if (filter == AppointmentFilter.rush && !bundle.job.isRush) continue;
      items.add(TodayReadyItem(bundle));
    }
  }

  items.sort(
    (a, b) => compareListKeys(
      sort: sort,
      aName: a.customerName,
      bName: b.customerName,
      aRush: a.isRush,
      bRush: b.isRush,
      aTime: a.sortTime,
      bTime: b.sortTime,
    ),
  );

  return items;
}
