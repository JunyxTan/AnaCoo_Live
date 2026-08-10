/// Shared scope for appointment agendas (home list, Calendar day, …).
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

/// Filters on a single calendar day (no overdue/ready job scopes).
const List<AppointmentFilter> dayAppointmentFilters = [
  AppointmentFilter.all,
  AppointmentFilter.dropOff,
  AppointmentFilter.collection,
  AppointmentFilter.rush,
];

/// Filters on the all-time appointments home list.
const List<AppointmentFilter> allAppointmentFilters = AppointmentFilter.values;
