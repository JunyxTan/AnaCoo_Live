import '../data/database.dart';
import '../data/enums.dart';

/// What the Today list is scoped to.
enum TodayFilter {
  all,
  dropOff,
  collection,
  overdue,
  ready,
  rush,
}

/// How the Today list is ordered.
enum TodaySort {
  timeAsc,
  timeDesc,
  name,
  rushFirst,
}

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
  DateTime get sortTime => entry.appointment.scheduledAt;
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
  required TodayFilter filter,
  required TodaySort sort,
}) {
  final overdueIds = overdue.map((e) => e.appointment.id).toSet();
  final items = <TodayItem>[];

  bool includeAppointment(AppointmentEntry entry, {required bool isOverdue}) {
    return switch (filter) {
      TodayFilter.all => true,
      TodayFilter.dropOff =>
        entry.appointment.type == AppointmentType.dropOff,
      TodayFilter.collection =>
        entry.appointment.type == AppointmentType.collection,
      TodayFilter.overdue => isOverdue,
      TodayFilter.ready => false,
      TodayFilter.rush => entry.job.isRush,
    };
  }

  for (final entry in overdue) {
    if (includeAppointment(entry, isOverdue: true)) {
      items.add(TodayAppointmentItem(entry: entry, isOverdue: true));
    }
  }

  for (final entry in today) {
    if (overdueIds.contains(entry.appointment.id)) continue;
    if (includeAppointment(entry, isOverdue: false)) {
      items.add(TodayAppointmentItem(entry: entry, isOverdue: false));
    }
  }

  final includeReady = switch (filter) {
    TodayFilter.all || TodayFilter.ready => true,
    TodayFilter.rush => true,
    TodayFilter.dropOff ||
    TodayFilter.collection ||
    TodayFilter.overdue =>
      false,
  };
  if (includeReady) {
    for (final bundle in ready) {
      if (filter == TodayFilter.rush && !bundle.job.isRush) continue;
      items.add(TodayReadyItem(bundle));
    }
  }

  items.sort((a, b) {
    switch (sort) {
      case TodaySort.timeAsc:
        final byTime = a.sortTime.compareTo(b.sortTime);
        if (byTime != 0) return byTime;
        return a.customerName.toLowerCase().compareTo(b.customerName.toLowerCase());
      case TodaySort.timeDesc:
        final byTime = b.sortTime.compareTo(a.sortTime);
        if (byTime != 0) return byTime;
        return a.customerName.toLowerCase().compareTo(b.customerName.toLowerCase());
      case TodaySort.name:
        final byName =
            a.customerName.toLowerCase().compareTo(b.customerName.toLowerCase());
        if (byName != 0) return byName;
        return a.sortTime.compareTo(b.sortTime);
      case TodaySort.rushFirst:
        if (a.isRush != b.isRush) return a.isRush ? -1 : 1;
        final byTime = a.sortTime.compareTo(b.sortTime);
        if (byTime != 0) return byTime;
        return a.customerName.toLowerCase().compareTo(b.customerName.toLowerCase());
    }
  });

  return items;
}
