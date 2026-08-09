import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Everything the tailor sees is in shop time, regardless of what the device
/// clock says. Appointments are stored as UTC instants and rendered through
/// this location, so flying to another timezone (or a device clock change)
/// never shifts an appointment on screen or in a scheduled reminder.
const String shopTimeZoneName = 'Asia/Kuala_Lumpur';

bool _initialised = false;
late tz.Location _shopLocation;

/// Loads the timezone database and `intl`'s locale data.
///
/// Both are process-wide, synchronous and idempotent, and both are needed
/// before any appointment can be rendered or scheduled — including from a
/// background isolate, where no widget tree has run to set them up.
void initShopTime() {
  if (_initialised) return;
  tzdata.initializeTimeZones();
  // The bundled local data initialises synchronously; the returned future is
  // already complete.
  initializeDateFormatting();
  _shopLocation = tz.getLocation(shopTimeZoneName);
  tz.setLocalLocation(_shopLocation);
  _initialised = true;
}

tz.Location get shopLocation {
  initShopTime();
  return _shopLocation;
}

tz.TZDateTime shopNow() => tz.TZDateTime.now(shopLocation);

/// Reads a stored instant as shop wall-clock time.
tz.TZDateTime toShop(DateTime instant) =>
    tz.TZDateTime.from(instant.toUtc(), shopLocation);

/// Builds a shop-local wall-clock time.
tz.TZDateTime shopDateTime(
  int year,
  int month,
  int day, [
  int hour = 0,
  int minute = 0,
]) =>
    tz.TZDateTime(shopLocation, year, month, day, hour, minute);

/// The instant to persist for a shop-local wall-clock time.
DateTime toStorage(tz.TZDateTime local) => local.toUtc();

/// Midnight at the start of [at]'s day, in shop time.
tz.TZDateTime startOfDay(tz.TZDateTime at) =>
    tz.TZDateTime(at.location, at.year, at.month, at.day);

tz.TZDateTime endOfDay(tz.TZDateTime at) =>
    startOfDay(at).add(const Duration(days: 1));

tz.TZDateTime addDays(tz.TZDateTime at, int days) => tz.TZDateTime(
      at.location,
      at.year,
      at.month,
      at.day + days,
      at.hour,
      at.minute,
    );

/// `YYYY-MM-DD` in shop time — the key format used by `BlockedDates`.
String dayKey(tz.TZDateTime at) =>
    '${at.year.toString().padLeft(4, '0')}-'
    '${at.month.toString().padLeft(2, '0')}-'
    '${at.day.toString().padLeft(2, '0')}';

/// Parses a `YYYY-MM-DD` day key back to shop midnight. Returns null on junk.
tz.TZDateTime? parseDayKey(String key) {
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(key.trim());
  if (match == null) return null;
  final y = int.parse(match.group(1)!);
  final m = int.parse(match.group(2)!);
  final d = int.parse(match.group(3)!);
  if (m < 1 || m > 12 || d < 1 || d > 31) return null;
  final built = shopDateTime(y, m, d);
  if (built.month != m || built.day != d) return null;
  return built;
}

int minuteOfDay(tz.TZDateTime at) => at.hour * 60 + at.minute;

bool isSameDay(tz.TZDateTime a, tz.TZDateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
