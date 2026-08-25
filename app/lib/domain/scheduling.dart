import 'package:timezone/timezone.dart' as tz;

import '../data/enums.dart';
import 'shop_time.dart';
import 'working_hours.dart';

/// Nothing here ever blocks a save. The tailor knows their own diary better
/// than the app does — every rule below produces a *warning* that is shown
/// inline and can be ignored.
enum ScheduleWarningKind {
  closedDay,
  outsideWorkingHours,
  blockedDate,
  clash,
  inThePast,
  insideLeadTime,
}

class ScheduleWarning {
  const ScheduleWarning(this.kind, {this.clashCount = 0, this.clashType, this.reason});

  final ScheduleWarningKind kind;

  /// For [ScheduleWarningKind.clash]: how many appointments overlap.
  final int clashCount;

  /// For [ScheduleWarningKind.clash]: the type the majority of them are, used
  /// for "You already have 2 drop-offs at this time."
  final AppointmentType? clashType;

  /// For [ScheduleWarningKind.blockedDate]: the reason stored on the day.
  final String? reason;
}

/// A slice of the diary that a candidate appointment might collide with.
class BusySlot {
  const BusySlot({
    required this.id,
    required this.startUtc,
    required this.durationMinutes,
    required this.type,
    required this.status,
  });

  final int id;
  final DateTime startUtc;
  final int durationMinutes;
  final AppointmentType type;
  final AppointmentStatus status;

  DateTime get endUtc => startUtc.add(Duration(minutes: durationMinutes));
}

/// How much notice a new appointment needs. The pickers refuse to hand back an
/// earlier time, and anything that still lands inside the buffer — an old job
/// being edited, a pasted request asking for "in an hour" — raises
/// [ScheduleWarningKind.insideLeadTime].
const Duration bookingLeadTime = Duration(hours: 12);

/// The earliest instant a new appointment may be booked for: [bookingLeadTime]
/// after [now] (or the shop clock), and never on [now]'s own day.
///
/// The day rule is the point of the buffer, not a rounding detail. Twelve
/// hours from a 9am walk-in is 9pm, which would put the job in the last slot
/// or two of the same evening — technically 12 hours' notice, but not the
/// day-ahead breathing room the buffer exists to buy. Anything that clears
/// both rules stands: a time is bookable from the next day onwards.
///
/// Deliberately *not* pulled into working hours — being shut is a separate,
/// softer warning, and a closed day should not silently stretch the buffer.
tz.TZDateTime earliestBookable([tz.TZDateTime? now]) {
  final reference = now ?? shopNow();
  final afterLeadTime = reference.add(bookingLeadTime);
  final tomorrow = startOfDay(addDays(reference, 1));
  return afterLeadTime.isBefore(tomorrow) ? tomorrow : afterLeadTime;
}

/// Rounds [desired] to the nearest slot boundary and pulls it inside opening
/// hours, rolling forward to the next open day when the shop is shut.
///
/// Returns [desired] untouched if every weekday is closed — there is nowhere
/// sensible to snap to, and silently inventing a time would be worse.
tz.TZDateTime snapIntoWorkingHours(
  tz.TZDateTime desired,
  WorkingHours hours, {
  int slotMinutes = 30,
}) {
  if (hours.isClosedAllWeek || slotMinutes <= 0) return desired;

  var day = startOfDay(desired);
  var wantMinute = _roundToSlot(minuteOfDay(desired), slotMinutes);

  for (var attempt = 0; attempt < 14; attempt++) {
    final dayHours = hours.forWeekday(day.weekday);
    if (dayHours != null) {
      final lastStart = dayHours.closeMinutes - slotMinutes;
      if (lastStart >= dayHours.openMinutes) {
        if (wantMinute < dayHours.openMinutes) {
          wantMinute = dayHours.openMinutes;
        }
        if (wantMinute <= lastStart) {
          return day.add(Duration(minutes: wantMinute));
        }
      } else {
        // Opening window is shorter than one slot — start at opening time.
        return day.add(Duration(minutes: dayHours.openMinutes));
      }
    }
    // Try the next day, from its opening time.
    day = addDays(day, 1);
    wantMinute = 0;
  }
  return desired;
}

int _roundToSlot(int minute, int slotMinutes) {
  final rounded = ((minute + slotMinutes ~/ 2) ~/ slotMinutes) * slotMinutes;
  return rounded.clamp(0, 24 * 60 - 1);
}

/// [snapIntoWorkingHours], with the [earliestBookable] floor applied first —
/// the seed time every "new job" button starts from.
tz.TZDateTime snapIntoBookableHours(
  tz.TZDateTime desired,
  WorkingHours hours, {
  int slotMinutes = 30,
  tz.TZDateTime? now,
}) {
  final floor = earliestBookable(now);
  final start = desired.isBefore(floor) ? floor : desired;
  final snapped = snapIntoWorkingHours(start, hours, slotMinutes: slotMinutes);
  if (!snapped.isBefore(floor)) return snapped;
  // Rounding to the *nearest* slot dropped us back inside the buffer, so take
  // the slot above instead: a whole slot up minus at most half a slot of
  // rounding always lands clear of the floor.
  return snapIntoWorkingHours(
    start.add(Duration(minutes: slotMinutes)),
    hours,
    slotMinutes: slotMinutes,
  );
}

/// Every slot start the shop is open for on [day].
List<tz.TZDateTime> slotsForDay(
  tz.TZDateTime day,
  WorkingHours hours, {
  int slotMinutes = 30,
}) {
  final dayHours = hours.forWeekday(day.weekday);
  if (dayHours == null || slotMinutes <= 0) return const [];
  final midnight = startOfDay(day);
  final out = <tz.TZDateTime>[];
  for (var m = dayHours.openMinutes;
      m + slotMinutes <= dayHours.closeMinutes;
      m += slotMinutes) {
    out.add(midnight.add(Duration(minutes: m)));
  }
  return out;
}

/// The default collection time for a job dropped off at [dropOff].
tz.TZDateTime suggestCollection(
  tz.TZDateTime dropOff,
  WorkingHours hours, {
  required int turnaroundDays,
  int slotMinutes = 30,
}) =>
    snapIntoWorkingHours(
      addDays(dropOff, turnaroundDays),
      hours,
      slotMinutes: slotMinutes,
    );

/// Appointments overlapping the candidate window, excluding [excludeId].
List<BusySlot> clashesFor({
  required DateTime candidateStartUtc,
  required int candidateDurationMinutes,
  required Iterable<BusySlot> existing,
  int? excludeId,
}) {
  final start = candidateStartUtc.toUtc();
  final end = start.add(Duration(minutes: candidateDurationMinutes));
  return existing
      .where(
        (slot) =>
            slot.id != excludeId &&
            slot.status.isLive &&
            slot.startUtc.isBefore(end) &&
            slot.endUtc.isAfter(start),
      )
      .toList();
}

/// Everything worth telling the tailor about a proposed time.
List<ScheduleWarning> evaluateSchedule({
  required tz.TZDateTime at,
  required int durationMinutes,
  required WorkingHours hours,
  required Set<String> blockedDays,
  Map<String, String?> blockedReasons = const {},
  Iterable<BusySlot> existing = const [],
  int? excludeId,
  tz.TZDateTime? now,
}) {
  final warnings = <ScheduleWarning>[];

  final dayHours = hours.forWeekday(at.weekday);
  if (dayHours == null) {
    warnings.add(const ScheduleWarning(ScheduleWarningKind.closedDay));
  } else {
    final start = minuteOfDay(at);
    if (start < dayHours.openMinutes ||
        start + durationMinutes > dayHours.closeMinutes) {
      warnings.add(const ScheduleWarning(ScheduleWarningKind.outsideWorkingHours));
    }
  }

  final key = dayKey(at);
  if (blockedDays.contains(key)) {
    warnings.add(
      ScheduleWarning(
        ScheduleWarningKind.blockedDate,
        reason: blockedReasons[key],
      ),
    );
  }

  final clashes = clashesFor(
    candidateStartUtc: at.toUtc(),
    candidateDurationMinutes: durationMinutes,
    existing: existing,
    excludeId: excludeId,
  );
  if (clashes.isNotEmpty) {
    final dropOffs = clashes.where((c) => c.type == AppointmentType.dropOff).length;
    warnings.add(
      ScheduleWarning(
        ScheduleWarningKind.clash,
        clashCount: clashes.length,
        clashType: dropOffs * 2 >= clashes.length
            ? AppointmentType.dropOff
            : AppointmentType.collection,
      ),
    );
  }

  final reference = now ?? shopNow();
  if (at.isBefore(reference)) {
    warnings.add(const ScheduleWarning(ScheduleWarningKind.inThePast));
  } else if (at.isBefore(earliestBookable(reference))) {
    // Only worth saying when the time is still ahead of us — "in the past"
    // already covers the rest.
    warnings.add(const ScheduleWarning(ScheduleWarningKind.insideLeadTime));
  }

  return warnings;
}
