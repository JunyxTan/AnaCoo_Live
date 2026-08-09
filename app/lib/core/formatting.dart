import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import '../domain/shop_time.dart';

/// Date and time formatting, always in shop time and in the chosen UI language.
class Formats {
  const Formats(this.languageCode);

  final String languageCode;

  String get _locale => switch (languageCode) {
        'zh' => 'zh',
        'ms' => 'ms',
        _ => 'en',
      };

  String time(tz.TZDateTime at) => DateFormat.jm(_locale).format(at);

  String dayMonth(tz.TZDateTime at) => DateFormat.MMMd(_locale).format(at);

  String weekdayDayMonth(tz.TZDateTime at) => DateFormat.MMMEd(_locale).format(at);

  String fullDate(tz.TZDateTime at) => DateFormat.yMMMEd(_locale).format(at);

  String monthYear(tz.TZDateTime at) => DateFormat.yMMMM(_locale).format(at);

  String weekdayNarrow(int weekday) {
    // 2024-01-01 was a Monday, so this maps weekday 1..7 onto a real week.
    final probe = DateTime(2024, 1, weekday);
    return DateFormat.E(_locale).format(probe);
  }

  String weekdayFull(int weekday) =>
      DateFormat.EEEE(_locale).format(DateTime(2024, 1, weekday));

  String minutesAsClock(int minutesFromMidnight) {
    final probe = DateTime(2024, 1, 1, 0, minutesFromMidnight);
    return DateFormat.jm(_locale).format(probe);
  }

  String money(double? amount) =>
      amount == null ? '—' : 'RM ${amount.toStringAsFixed(2)}';

  /// "Today", "Tomorrow", or the date.
  String relativeDate(tz.TZDateTime at, {required String todayLabel, required String tomorrowLabel}) {
    final now = shopNow();
    if (isSameDay(at, now)) return todayLabel;
    if (isSameDay(at, addDays(now, 1))) return tomorrowLabel;
    return weekdayDayMonth(at);
  }

  String dateAndTime(tz.TZDateTime at) => '${weekdayDayMonth(at)} · ${time(at)}';
}
