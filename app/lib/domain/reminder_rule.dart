import 'package:timezone/timezone.dart' as tz;

/// When to fire a reminder relative to an appointment.
///
/// The spec calls this field `reminderOffsets (List<Duration>)`, but one of the
/// two defaults — *"1 day before at 9:00 PM"* — is a wall-clock rule, not an
/// offset: an 11 AM and a 9 PM appointment both want the 9 PM nudge the evening
/// before. A plain `Duration` cannot express that, so the field carries two rule
/// shapes and resolves both against the shop timezone.
sealed class ReminderRule {
  const ReminderRule();

  /// Absolute local time this rule fires for [appointment].
  tz.TZDateTime resolve(tz.TZDateTime appointment);

  String encode();

  static ReminderRule? decode(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return null;
    final colon = s.indexOf(':');
    if (colon < 0) return null;
    final kind = s.substring(0, colon);
    final arg = s.substring(colon + 1);
    switch (kind) {
      case 'before':
        final minutes = int.tryParse(arg);
        if (minutes == null || minutes < 0) return null;
        return RelativeReminder(Duration(minutes: minutes));
      case 'dayBefore':
        // dayBefore:<days>@<hour>:<minute>
        final at = arg.split('@');
        if (at.length != 2) return null;
        final days = int.tryParse(at[0]);
        final hm = at[1].split(':');
        if (days == null || days < 0 || hm.length != 2) return null;
        final hour = int.tryParse(hm[0]);
        final minute = int.tryParse(hm[1]);
        if (hour == null || minute == null) return null;
        if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
        return DaysBeforeAtReminder(days: days, hour: hour, minute: minute);
      default:
        return null;
    }
  }

  static String encodeList(List<ReminderRule> rules) =>
      rules.map((r) => r.encode()).join(',');

  static List<ReminderRule> decodeList(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const [];
    final out = <ReminderRule>[];
    for (final part in raw.split(',')) {
      final rule = ReminderRule.decode(part);
      if (rule != null) out.add(rule);
    }
    return out;
  }

  /// 1 day before at 9:00 PM, and 1 hour before.
  static const List<ReminderRule> defaults = [
    DaysBeforeAtReminder(days: 1, hour: 21, minute: 0),
    RelativeReminder(Duration(hours: 1)),
  ];
}

/// Fires [before] ahead of the appointment instant.
class RelativeReminder extends ReminderRule {
  const RelativeReminder(this.before);

  final Duration before;

  @override
  tz.TZDateTime resolve(tz.TZDateTime appointment) => appointment.subtract(before);

  @override
  String encode() => 'before:${before.inMinutes}';

  @override
  bool operator ==(Object other) => other is RelativeReminder && other.before == before;

  @override
  int get hashCode => Object.hash('before', before);

  @override
  String toString() => 'RelativeReminder(${before.inMinutes}m)';
}

/// Fires [days] calendar days earlier at a fixed local wall-clock time.
class DaysBeforeAtReminder extends ReminderRule {
  const DaysBeforeAtReminder({
    required this.days,
    required this.hour,
    required this.minute,
  });

  final int days;
  final int hour;
  final int minute;

  @override
  tz.TZDateTime resolve(tz.TZDateTime appointment) {
    // Build the wall-clock time first, then step back whole calendar days, so a
    // DST-shifting location can never turn "9 PM" into 8 PM.
    final sameDay = tz.TZDateTime(
      appointment.location,
      appointment.year,
      appointment.month,
      appointment.day,
      hour,
      minute,
    );
    if (days == 0) return sameDay;
    final target = DateTime(sameDay.year, sameDay.month, sameDay.day - days);
    return tz.TZDateTime(
      appointment.location,
      target.year,
      target.month,
      target.day,
      hour,
      minute,
    );
  }

  @override
  String encode() =>
      'dayBefore:$days@${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) =>
      other is DaysBeforeAtReminder &&
      other.days == days &&
      other.hour == hour &&
      other.minute == minute;

  @override
  int get hashCode => Object.hash('dayBefore', days, hour, minute);

  @override
  String toString() => 'DaysBeforeAtReminder($days d @ $hour:$minute)';
}
