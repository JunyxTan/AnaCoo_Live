import '../data/database.dart';
import '../data/enums.dart';
import 'list_query.dart';

export 'list_query.dart';

/// Whether [entry] belongs in an agenda under [filter].
///
/// [isOverdue] is only meaningful for Today’s overdue feed; day agendas pass
/// `false`.
bool appointmentMatchesFilter(
  AppointmentEntry entry,
  AppointmentFilter filter, {
  bool isOverdue = false,
}) {
  return switch (filter) {
    AppointmentFilter.all => true,
    AppointmentFilter.dropOff =>
      entry.appointment.type == AppointmentType.dropOff,
    AppointmentFilter.collection =>
      entry.appointment.type == AppointmentType.collection,
    AppointmentFilter.overdue => isOverdue,
    AppointmentFilter.ready => false,
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

/// Filters + sorts a single day’s appointments (Calendar agenda).
List<AppointmentEntry> buildDayAppointmentItems({
  required List<AppointmentEntry> entries,
  required AppointmentFilter filter,
  required AppointmentSort sort,
}) {
  final filtered = entries
      .where((entry) => appointmentMatchesFilter(entry, filter))
      .toList();
  filtered.sort((a, b) => compareAppointmentEntries(a, b, sort));
  return filtered;
}

/// Shared comparison used by Today rows and day agendas.
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
