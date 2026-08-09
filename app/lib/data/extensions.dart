import 'package:timezone/timezone.dart' as tz;

import '../domain/scheduling.dart';
import '../domain/shop_time.dart';
import 'database.dart';

extension AppointmentTimes on Appointment {
  /// The appointment in shop wall-clock time.
  tz.TZDateTime get at => toShop(scheduledAt);

  tz.TZDateTime get endsAt => at.add(Duration(minutes: durationMinutes));

  BusySlot get busySlot => BusySlot(
        id: id,
        startUtc: scheduledAt,
        durationMinutes: durationMinutes,
        type: type,
        status: status,
      );
}

extension AppointmentEntryTimes on AppointmentEntry {
  tz.TZDateTime get at => appointment.at;
}
