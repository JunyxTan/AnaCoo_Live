/// Shared scope for appointment agendas (Today, Calendar day, …).
enum AppointmentFilter {
  all,
  dropOff,
  collection,
  overdue,
  ready,
  rush,
}

/// Shared ordering for appointment agendas.
enum AppointmentSort {
  timeAsc,
  timeDesc,
  name,
  rushFirst,
}

/// Filters that make sense on a single calendar day (no overdue/ready feeds).
const List<AppointmentFilter> dayAppointmentFilters = [
  AppointmentFilter.all,
  AppointmentFilter.dropOff,
  AppointmentFilter.collection,
  AppointmentFilter.rush,
];

/// Filters available on the Today home list.
const List<AppointmentFilter> todayAppointmentFilters = AppointmentFilter.values;
