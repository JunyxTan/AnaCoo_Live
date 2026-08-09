import 'package:anacoo_tailor/data/enums.dart';
import 'package:anacoo_tailor/domain/scheduling.dart';
import 'package:anacoo_tailor/domain/shop_time.dart';
import 'package:anacoo_tailor/domain/working_hours.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  initShopTime();

  const hours = WorkingHours.anacooDefault; // Mon–Sun 11:00–22:00

  group('snapping into working hours', () {
    test('leaves a time that is already inside the window alone', () {
      final at = shopDateTime(2026, 8, 6, 14, 30);
      expect(snapIntoWorkingHours(at, hours), at);
    });

    test('rounds to the nearest slot boundary', () {
      expect(
        snapIntoWorkingHours(shopDateTime(2026, 8, 6, 14, 20), hours),
        shopDateTime(2026, 8, 6, 14, 30),
      );
      expect(
        snapIntoWorkingHours(shopDateTime(2026, 8, 6, 14, 10), hours),
        shopDateTime(2026, 8, 6, 14, 0),
      );
    });

    test('pulls an early morning time forward to opening', () {
      expect(
        snapIntoWorkingHours(shopDateTime(2026, 8, 6, 7, 0), hours),
        shopDateTime(2026, 8, 6, 11, 0),
      );
    });

    test('pushes a late night time to the next day', () {
      expect(
        snapIntoWorkingHours(shopDateTime(2026, 8, 6, 23, 30), hours),
        shopDateTime(2026, 8, 7, 11, 0),
      );
    });

    test('skips a closed weekday', () {
      final closedSundays = hours.withDay(DateTime.sunday, null);
      // 2026-08-09 is a Sunday.
      expect(
        snapIntoWorkingHours(shopDateTime(2026, 8, 9, 12, 0), closedSundays),
        shopDateTime(2026, 8, 10, 11, 0),
      );
    });

    test('gives up gracefully when the shop is never open', () {
      var closed = hours;
      for (var d = 1; d <= 7; d++) {
        closed = closed.withDay(d, null);
      }
      final at = shopDateTime(2026, 8, 6, 12, 0);
      expect(snapIntoWorkingHours(at, closed), at);
    });
  });

  group('collection suggestion', () {
    test('is the drop-off plus the turnaround, inside working hours', () {
      final dropOff = shopDateTime(2026, 8, 6, 12, 0);
      expect(
        suggestCollection(dropOff, hours, turnaroundDays: 3),
        shopDateTime(2026, 8, 9, 12, 0),
      );
    });

    test('lands at opening time when the turnaround crosses into a closed day',
        () {
      final closedSundays = hours.withDay(DateTime.sunday, null);
      final dropOff = shopDateTime(2026, 8, 6, 12, 0); // Thursday
      expect(
        suggestCollection(dropOff, closedSundays, turnaroundDays: 3),
        shopDateTime(2026, 8, 10, 11, 0), // Sunday is shut, so Monday
      );
    });
  });

  group('warnings', () {
    BusySlot slot(int id, int hour, {int minutes = 15, AppointmentType type = AppointmentType.dropOff}) =>
        BusySlot(
          id: id,
          startUtc: shopDateTime(2026, 8, 6, hour).toUtc(),
          durationMinutes: minutes,
          type: type,
          status: AppointmentStatus.confirmed,
        );

    test('a time inside working hours with a free diary raises nothing', () {
      final warnings = evaluateSchedule(
        at: shopDateTime(2026, 8, 6, 14, 0),
        durationMinutes: 15,
        hours: hours,
        blockedDays: const {},
        now: shopDateTime(2026, 8, 1, 10, 0),
      );
      expect(warnings, isEmpty);
    });

    test('warns, but does not block, outside working hours', () {
      final warnings = evaluateSchedule(
        at: shopDateTime(2026, 8, 6, 9, 0),
        durationMinutes: 15,
        hours: hours,
        blockedDays: const {},
        now: shopDateTime(2026, 8, 1, 10, 0),
      );
      expect(
        warnings.map((w) => w.kind),
        contains(ScheduleWarningKind.outsideWorkingHours),
      );
    });

    test('warns on a blocked date and carries its reason', () {
      final warnings = evaluateSchedule(
        at: shopDateTime(2026, 8, 6, 14, 0),
        durationMinutes: 15,
        hours: hours,
        blockedDays: const {'2026-08-06'},
        blockedReasons: const {'2026-08-06': 'Hari Raya'},
        now: shopDateTime(2026, 8, 1, 10, 0),
      );
      final blocked =
          warnings.firstWhere((w) => w.kind == ScheduleWarningKind.blockedDate);
      expect(blocked.reason, 'Hari Raya');
    });

    test('counts overlapping drop-offs for the inline clash message', () {
      final warnings = evaluateSchedule(
        at: shopDateTime(2026, 8, 6, 14, 0),
        durationMinutes: 30,
        hours: hours,
        blockedDays: const {},
        existing: [slot(1, 14), slot(2, 14)],
        now: shopDateTime(2026, 8, 1, 10, 0),
      );
      final clash =
          warnings.firstWhere((w) => w.kind == ScheduleWarningKind.clash);
      expect(clash.clashCount, 2);
      expect(clash.clashType, AppointmentType.dropOff);
    });

    test('an appointment does not clash with itself when edited', () {
      final warnings = evaluateSchedule(
        at: shopDateTime(2026, 8, 6, 14, 0),
        durationMinutes: 15,
        hours: hours,
        blockedDays: const {},
        existing: [slot(7, 14)],
        excludeId: 7,
        now: shopDateTime(2026, 8, 1, 10, 0),
      );
      expect(warnings, isEmpty);
    });

    test('cancelled appointments are not clash candidates', () {
      final cancelled = BusySlot(
        id: 3,
        startUtc: shopDateTime(2026, 8, 6, 14).toUtc(),
        durationMinutes: 30,
        type: AppointmentType.dropOff,
        status: AppointmentStatus.cancelled,
      );
      final warnings = evaluateSchedule(
        at: shopDateTime(2026, 8, 6, 14, 0),
        durationMinutes: 15,
        hours: hours,
        blockedDays: const {},
        existing: [cancelled],
        now: shopDateTime(2026, 8, 1, 10, 0),
      );
      expect(warnings, isEmpty);
    });

    test('back-to-back appointments do not count as a clash', () {
      final warnings = evaluateSchedule(
        at: shopDateTime(2026, 8, 6, 14, 15),
        durationMinutes: 15,
        hours: hours,
        blockedDays: const {},
        existing: [slot(1, 14)],
        now: shopDateTime(2026, 8, 1, 10, 0),
      );
      expect(warnings, isEmpty);
    });

    test('warns about a time in the past', () {
      final warnings = evaluateSchedule(
        at: shopDateTime(2026, 8, 1, 9, 0),
        durationMinutes: 15,
        hours: hours,
        blockedDays: const {},
        now: shopDateTime(2026, 8, 1, 10, 0),
      );
      expect(
        warnings.map((w) => w.kind),
        contains(ScheduleWarningKind.inThePast),
      );
    });
  });

  group('slots for a day', () {
    test('run from opening to the last slot that fits before closing', () {
      final slots = slotsForDay(shopDateTime(2026, 8, 6), hours, slotMinutes: 60);
      expect(slots.first, shopDateTime(2026, 8, 6, 11, 0));
      expect(slots.last, shopDateTime(2026, 8, 6, 21, 0));
      expect(slots.length, 11);
    });

    test('are empty on a closed day', () {
      final closed = hours.withDay(DateTime.thursday, null);
      expect(slotsForDay(shopDateTime(2026, 8, 6), closed), isEmpty);
    });
  });

  group('shop time', () {
    test('day keys round trip', () {
      final day = shopDateTime(2026, 8, 6);
      expect(dayKey(day), '2026-08-06');
      expect(parseDayKey('2026-08-06'), day);
      expect(parseDayKey('nonsense'), isNull);
      expect(parseDayKey('2026-13-01'), isNull);
    });

    test('a stored instant reads back as the same shop wall clock', () {
      final local = shopDateTime(2026, 8, 6, 12, 0);
      final stored = toStorage(local);
      expect(stored.isUtc, isTrue);
      expect(toShop(stored), local);
      // Kuala Lumpur is UTC+8 year round.
      expect(stored.hour, 4);
    });

    test('working hours survive an encode/decode round trip', () {
      final custom = WorkingHours.anacooDefault
          .withDay(DateTime.sunday, null)
          .withDay(
            DateTime.monday,
            const DayHours(openMinutes: 600, closeMinutes: 1200),
          );
      final decoded = WorkingHours.decode(custom.encode());
      expect(decoded, custom);
      expect(decoded.isOpenOn(DateTime.sunday), isFalse);
      expect(decoded.forWeekday(DateTime.monday)!.openMinutes, 600);
    });

    test('garbage settings fall back to the shop defaults', () {
      expect(WorkingHours.decode('not json'), WorkingHours.anacooDefault);
      expect(WorkingHours.decode(null), WorkingHours.anacooDefault);
    });
  });
}
