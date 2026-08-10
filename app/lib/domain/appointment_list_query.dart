import '../data/database.dart';
import '../data/enums.dart';
import 'list_query.dart';

export 'list_query.dart';

/// Live appointment whose scheduled time is already past.
bool isAppointmentOverdue(AppointmentEntry entry, DateTime nowUtc) {
  if (!entry.appointment.status.isLive) return false;
  if (entry.job.status.isClosed) return false;
  return entry.appointment.scheduledAt.isBefore(nowUtc);
}

/// Whether [entry] belongs under [filter].
///
/// Pass [nowUtc] so overdue/ready can be decided from the row itself (all-time
/// list). Day agendas can omit it when those filters are not offered.
bool appointmentMatchesFilter(
  AppointmentEntry entry,
  AppointmentFilter filter, {
  DateTime? nowUtc,
}) {
  return switch (filter) {
    AppointmentFilter.all => true,
    AppointmentFilter.dropOff =>
      entry.appointment.type == AppointmentType.dropOff,
    AppointmentFilter.collection =>
      entry.appointment.type == AppointmentType.collection,
    AppointmentFilter.overdue =>
      nowUtc != null && isAppointmentOverdue(entry, nowUtc),
    AppointmentFilter.ready => entry.job.status == JobStatus.ready,
    AppointmentFilter.rush => entry.job.isRush,
  };
}

/// Sort key for a bare appointment row.
DateTime appointmentSortTime(AppointmentEntry entry) =>
    entry.appointment.scheduledAt;

int compareAppointmentEntries(
  AppointmentEntry a,
  AppointmentEntry b,
  AppointmentSort sort,
) {
  return compareListKeys(
    sort: sort,
    aName: a.customer.name,
    bName: b.customer.name,
    aRush: a.job.isRush,
    bRush: b.job.isRush,
    aTime: appointmentSortTime(a),
    bTime: appointmentSortTime(b),
  );
}

/// Filters + sorts any appointment list (all-time home or a calendar day).
List<AppointmentEntry> buildAppointmentItems({
  required List<AppointmentEntry> entries,
  required AppointmentFilter filter,
  required AppointmentSort sort,
  DateTime? nowUtc,
}) {
  final filtered = entries
      .where(
        (entry) => appointmentMatchesFilter(entry, filter, nowUtc: nowUtc),
      )
      .toList();
  filtered.sort((a, b) => compareAppointmentEntries(a, b, sort));
  return filtered;
}

/// Calendar day agenda — same builder, without overdue/ready time context.
List<AppointmentEntry> buildDayAppointmentItems({
  required List<AppointmentEntry> entries,
  required AppointmentFilter filter,
  required AppointmentSort sort,
}) =>
    buildAppointmentItems(
      entries: entries,
      filter: filter,
      sort: sort,
    );

/// Shared comparison used by appointment rows.
int compareListKeys({
  required AppointmentSort sort,
  required String aName,
  required String bName,
  required bool aRush,
  required bool bRush,
  required DateTime aTime,
  required DateTime bTime,
}) {
  final aNameKey = aName.toLowerCase();
  final bNameKey = bName.toLowerCase();
  switch (sort) {
    case AppointmentSort.timeAsc:
      final byTime = aTime.compareTo(bTime);
      if (byTime != 0) return byTime;
      return aNameKey.compareTo(bNameKey);
    case AppointmentSort.timeDesc:
      final byTime = bTime.compareTo(aTime);
      if (byTime != 0) return byTime;
      return aNameKey.compareTo(bNameKey);
    case AppointmentSort.name:
      final byName = aNameKey.compareTo(bNameKey);
      if (byName != 0) return byName;
      return aTime.compareTo(bTime);
    case AppointmentSort.rushFirst:
      if (aRush != bRush) return aRush ? -1 : 1;
      final byTime = aTime.compareTo(bTime);
      if (byTime != 0) return byTime;
      return aNameKey.compareTo(bNameKey);
  }
}
