import 'text_cleaner.dart';

/// A calendar date with no timezone attached — the parser's job is to read what
/// the customer typed, not to decide which instant that is.
class ParsedDate {
  const ParsedDate(this.year, this.month, this.day);

  final int year;
  final int month;
  final int day;

  DateTime toDateTime() => DateTime(year, month, day);

  @override
  bool operator ==(Object other) =>
      other is ParsedDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => '$year-${_pad2(month)}-${_pad2(day)}';
}

class ParsedTime {
  const ParsedTime(this.hour, this.minute);

  final int hour;
  final int minute;

  @override
  bool operator ==(Object other) =>
      other is ParsedTime && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => Object.hash(hour, minute);

  @override
  String toString() => '${_pad2(hour)}:${_pad2(minute)}';
}

String _pad2(int v) => v.toString().padLeft(2, '0');

const Map<String, int> _monthNames = {
  'jan': 1, 'january': 1, 'januari': 1,
  'feb': 2, 'february': 2, 'februari': 2,
  'mar': 3, 'march': 3, 'mac': 3,
  'apr': 4, 'april': 4,
  'may': 5, 'mei': 5,
  'jun': 6, 'june': 6, 'jun.': 6,
  'jul': 7, 'july': 7, 'julai': 7,
  'aug': 8, 'august': 8, 'ogo': 8, 'ogos': 8,
  'sep': 9, 'sept': 9, 'september': 9,
  'oct': 10, 'october': 10, 'okt': 10, 'oktober': 10,
  'nov': 11, 'november': 11,
  'dec': 12, 'december': 12, 'dis': 12, 'disember': 12,
};

/// `today` / `tomorrow` / `the day after` in the UI languages.
const Map<String, int> _relativeDays = {
  'today': 0, 'hari ini': 0, 'harini': 0, '今天': 0, '今日': 0,
  'hôm nay': 0, 'hom nay': 0,
  'tomorrow': 1, 'tmr': 1, 'tmrw': 1, 'esok': 1, 'besok': 1, '明天': 1, '明日': 1,
  'ngày mai': 1, 'ngay mai': 1, 'mai': 1,
  'day after tomorrow': 2, 'lusa': 2, '后天': 2, '後天': 2,
  'ngày kia': 2, 'ngay kia': 2, 'ngày mốt': 2, 'ngay mot': 2, 'mốt': 2,
};

final RegExp _isoDate = RegExp(r'(\d{4})[-/.](\d{1,2})[-/.](\d{1,2})');

/// Day-first, always. `6/8/2026` is 6 August in MY/SG, never 8 June.
final RegExp _dayFirstDate = RegExp(r'(\d{1,2})[-/.](\d{1,2})(?:[-/.](\d{2,4}))?');

final RegExp _cjkDate = RegExp(r'(?:(\d{4})\s*年\s*)?(\d{1,2})\s*月\s*(\d{1,2})\s*日?');

/// `6 tháng 8`, `6 thg 8 2026`, `ngày 6 tháng 8 năm 2026`. Vietnamese numbers
/// its months behind a keyword instead of naming them, so the Latin
/// month-name patterns below never see it.
final RegExp _vietnameseDate = RegExp(
  r'(\d{1,2})\s*(?:th[áa]ng|thg)\.?\s*(\d{1,2})(?:\s*(?:n[ăa]m\s*)?(\d{4}))?',
  caseSensitive: false,
);

final RegExp _dayMonthName = RegExp(
  r'(\d{1,2})\s*(?:st|nd|rd|th)?[\s.,-]+([A-Za-z]{3,9})\.?(?:[\s.,-]+(\d{2,4}))?',
  caseSensitive: false,
);

final RegExp _monthNameDay = RegExp(
  r'([A-Za-z]{3,9})\.?[\s.,-]+(\d{1,2})(?:st|nd|rd|th)?(?:[\s.,-]+(\d{2,4}))?',
  caseSensitive: false,
);

/// Reads a date out of [input]. [today] anchors the relative keywords and
/// supplies the year when the customer omitted it.
ParsedDate? parseDate(String input, {required DateTime today}) {
  final text = stripEmoji(input).trim();
  if (text.isEmpty) return null;

  final probe = normaliseForMatching(text);
  for (final entry in _relativeDays.entries) {
    if (probe == entry.key || probe.startsWith('${entry.key} ')) {
      final d = DateTime(today.year, today.month, today.day + entry.value);
      return ParsedDate(d.year, d.month, d.day);
    }
  }
  // CJK keywords carry no word boundaries, so match them as substrings.
  for (final entry in _relativeDays.entries) {
    if (entry.key.codeUnitAt(0) > 0x2000 && text.contains(entry.key)) {
      final d = DateTime(today.year, today.month, today.day + entry.value);
      return ParsedDate(d.year, d.month, d.day);
    }
  }

  final cjk = _cjkDate.firstMatch(text);
  if (cjk != null) {
    final year = cjk.group(1) == null ? today.year : int.parse(cjk.group(1)!);
    return _validate(year, int.parse(cjk.group(2)!), int.parse(cjk.group(3)!));
  }

  final vietnamese = _vietnameseDate.firstMatch(text);
  if (vietnamese != null) {
    return _validate(
      _expandYear(vietnamese.group(3), today),
      int.parse(vietnamese.group(2)!),
      int.parse(vietnamese.group(1)!),
    );
  }

  final iso = _isoDate.firstMatch(text);
  if (iso != null) {
    return _validate(
      int.parse(iso.group(1)!),
      int.parse(iso.group(2)!),
      int.parse(iso.group(3)!),
    );
  }

  final dayMonth = _dayMonthName.firstMatch(text);
  if (dayMonth != null) {
    final month = _monthNames[dayMonth.group(2)!.toLowerCase()];
    if (month != null) {
      return _validate(
        _expandYear(dayMonth.group(3), today),
        month,
        int.parse(dayMonth.group(1)!),
      );
    }
  }

  final monthDay = _monthNameDay.firstMatch(text);
  if (monthDay != null) {
    final month = _monthNames[monthDay.group(1)!.toLowerCase()];
    if (month != null) {
      return _validate(
        _expandYear(monthDay.group(3), today),
        month,
        int.parse(monthDay.group(2)!),
      );
    }
  }

  final dayFirst = _dayFirstDate.firstMatch(text);
  if (dayFirst != null) {
    final a = int.parse(dayFirst.group(1)!);
    final b = int.parse(dayFirst.group(2)!);
    final year = _expandYear(dayFirst.group(3), today);
    // Day-first unless that is impossible and the reverse reading works.
    if (a <= 31 && b <= 12) return _validate(year, b, a);
    if (b <= 31 && a <= 12) return _validate(year, a, b);
    return null;
  }

  return null;
}

int _expandYear(String? raw, DateTime today) {
  if (raw == null) return today.year;
  final value = int.tryParse(raw);
  if (value == null) return today.year;
  if (raw.length >= 4) return value;
  return 2000 + value;
}

ParsedDate? _validate(int year, int month, int day) {
  if (month < 1 || month > 12 || day < 1 || day > 31) return null;
  if (year < 1900 || year > 2200) return null;
  final probe = DateTime(year, month, day);
  if (probe.month != month || probe.day != day) return null;
  return ParsedDate(year, month, day);
}

const Map<String, bool> _meridiemPm = {
  'am': false, 'a m': false, 'pagi': false, '上午': false, '早上': false, '凌晨': false,
  'sáng': false, 'sang': false,
  'pm': true, 'p m': true, 'petang': true, 'malam': true, 'tengahari': true,
  'tengah hari': true, '下午': true, '晚上': true, '中午': true, '傍晚': true,
  'chiều': true, 'chieu': true, 'tối': true, 'toi': true, 'trưa': true,
  'trua': true, 'đêm': true,
};

final RegExp _separatedTime = RegExp(r'(\d{1,2})\s*[:.：h]\s*(\d{2})');

/// `8h`, `20 h` — Vietnamese marks a whole hour with a trailing `h` and no
/// minutes. The negative lookahead keeps it off English words like `8 hours`.
final RegExp _hourMarkerOnly = RegExp(
  r'(?<!\d)(\d{1,2})\s*h(?![a-z0-9])',
  caseSensitive: false,
);
final RegExp _bareHourWithMeridiem = RegExp(
  r'(\d{1,2})\s*(am|pm|a\.m\.|p\.m\.)',
  caseSensitive: false,
);
final RegExp _fourDigitTime = RegExp(r'\b(\d{4})\b');
final RegExp _standaloneHour = RegExp(r'(?<!\d)(\d{1,2})(?!\d)');

/// Reads a clock time out of [input].
///
/// [allowBareDigits] enables the `1400` form. It is on for the value of a
/// labelled Time field and off when scanning loose prose, where a bare four
/// digit run is far more likely to be a year.
ParsedTime? parseTime(String input, {bool allowBareDigits = true}) {
  final text = stripEmoji(input).trim();
  if (text.isEmpty) return null;

  final lower = text.toLowerCase();
  bool? pm;
  for (final entry in _meridiemPm.entries) {
    if (entry.key.codeUnitAt(0) > 0x2000) {
      if (text.contains(entry.key)) pm = entry.value;
    } else if (RegExp('(?<![a-z])${RegExp.escape(entry.key)}(?![a-z])')
        .hasMatch(lower.replaceAll('.', ' '))) {
      pm = entry.value;
    }
  }

  final separated = _separatedTime.firstMatch(text);
  if (separated != null) {
    return _buildTime(
      int.parse(separated.group(1)!),
      int.parse(separated.group(2)!),
      pm,
    );
  }

  final bare = _bareHourWithMeridiem.firstMatch(text);
  if (bare != null) {
    return _buildTime(int.parse(bare.group(1)!), 0, pm ?? true);
  }

  final hourMarker = _hourMarkerOnly.firstMatch(text);
  if (hourMarker != null) {
    return _buildTime(int.parse(hourMarker.group(1)!), 0, pm);
  }

  // "8 malam", "11 pagi", "下午 3" — the meridiem word is detached from the
  // hour, so pair the marker we already found with the only number present.
  if (pm != null) {
    final loneHour = _standaloneHour.firstMatch(text);
    if (loneHour != null) {
      return _buildTime(int.parse(loneHour.group(1)!), 0, pm);
    }
  }

  if (allowBareDigits) {
    final four = _fourDigitTime.firstMatch(text);
    if (four != null) {
      final digits = four.group(1)!;
      final hour = int.parse(digits.substring(0, 2));
      final minute = int.parse(digits.substring(2));
      final built = _buildTime(hour, minute, pm);
      if (built != null) return built;
    }
    // A lone hour, e.g. a Time field holding just "3".
    final loneHour = RegExp(r'^\s*(\d{1,2})\s*$').firstMatch(text);
    if (loneHour != null) {
      return _buildTime(int.parse(loneHour.group(1)!), 0, pm);
    }
  }

  return null;
}

ParsedTime? _buildTime(int rawHour, int minute, bool? pm) {
  if (minute < 0 || minute > 59) return null;
  var hour = rawHour;
  if (pm != null) {
    if (hour < 1 || hour > 12) {
      // "14:00 pm" — the 24h reading wins over a contradictory marker.
      if (hour < 0 || hour > 23) return null;
      return ParsedTime(hour, minute);
    }
    if (pm && hour != 12) hour += 12;
    if (!pm && hour == 12) hour = 0;
  }
  if (hour < 0 || hour > 23) return null;
  return ParsedTime(hour, minute);
}
