import 'dart:convert';

/// Opening window for one weekday, as minutes from local midnight.
class DayHours {
  const DayHours({required this.openMinutes, required this.closeMinutes});

  final int openMinutes;
  final int closeMinutes;

  bool contains(int minuteOfDay) =>
      minuteOfDay >= openMinutes && minuteOfDay < closeMinutes;

  Map<String, Object?> toJson() => {'open': openMinutes, 'close': closeMinutes};

  static DayHours? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final open = raw['open'];
    final close = raw['close'];
    if (open is! int || close is! int) return null;
    if (close <= open) return null;
    return DayHours(openMinutes: open, closeMinutes: close);
  }

  @override
  bool operator ==(Object other) =>
      other is DayHours &&
      other.openMinutes == openMinutes &&
      other.closeMinutes == closeMinutes;

  @override
  int get hashCode => Object.hash(openMinutes, closeMinutes);
}

/// Opening hours for the week, keyed by `DateTime.weekday` (1 = Monday).
/// A missing or null entry means the shop is closed that day.
class WorkingHours {
  const WorkingHours(this._byWeekday);

  final Map<int, DayHours?> _byWeekday;

  /// AnaCoo Tailor: Mon–Sun, 11:00–22:00.
  static const WorkingHours anacooDefault = WorkingHours({
    DateTime.monday: DayHours(openMinutes: 11 * 60, closeMinutes: 22 * 60),
    DateTime.tuesday: DayHours(openMinutes: 11 * 60, closeMinutes: 22 * 60),
    DateTime.wednesday: DayHours(openMinutes: 11 * 60, closeMinutes: 22 * 60),
    DateTime.thursday: DayHours(openMinutes: 11 * 60, closeMinutes: 22 * 60),
    DateTime.friday: DayHours(openMinutes: 11 * 60, closeMinutes: 22 * 60),
    DateTime.saturday: DayHours(openMinutes: 11 * 60, closeMinutes: 22 * 60),
    DateTime.sunday: DayHours(openMinutes: 11 * 60, closeMinutes: 22 * 60),
  });

  DayHours? forWeekday(int weekday) => _byWeekday[weekday];

  bool isOpenOn(int weekday) => _byWeekday[weekday] != null;

  bool get isClosedAllWeek =>
      List.generate(7, (i) => i + 1).every((d) => !isOpenOn(d));

  WorkingHours withDay(int weekday, DayHours? hours) =>
      WorkingHours({..._byWeekday, weekday: hours});

  String encode() => jsonEncode({
    for (var d = 1; d <= 7; d++) '$d': _byWeekday[d]?.toJson(),
  });

  static WorkingHours decode(String? raw) {
    if (raw == null || raw.trim().isEmpty) return anacooDefault;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return anacooDefault;
      return WorkingHours({
        for (var d = 1; d <= 7; d++) d: DayHours.fromJson(decoded['$d']),
      });
    } on FormatException {
      return anacooDefault;
    }
  }

  @override
  bool operator ==(Object other) =>
      other is WorkingHours &&
      List.generate(7, (i) => i + 1)
          .every((d) => other.forWeekday(d) == forWeekday(d));

  @override
  int get hashCode =>
      Object.hashAll(List.generate(7, (i) => _byWeekday[i + 1]));
}
