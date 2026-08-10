import 'package:drift/drift.dart';

import 'enums.dart';

class Customers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(max: 160)();

  /// E.164 where we could normalise it (MY/SG), raw input otherwise.
  TextColumn get phone => text().nullable()();
  TextColumn get whatsappNumber => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

class Jobs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get customerId =>
      integer().references(Customers, #id, onDelete: KeyAction.cascade)();
  TextColumn get service => textEnum<ServiceType>()();

  /// Free text that goes with the enum — always populated for
  /// [ServiceType.other], and used to keep the customer's own wording.
  TextColumn get serviceFreeText => text().nullable()();
  TextColumn get itemDescription => text().nullable()();
  IntColumn get quantity => integer().withDefault(const Constant(1))();

  /// MYR. Nullable — most jobs are quoted after the garment is seen.
  RealColumn get quotedPrice => real().nullable()();
  RealColumn get depositPaid => real().nullable()();
  TextColumn get status => textEnum<JobStatus>()();
  BoolColumn get isRush => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();

  /// Whatever arrived over WhatsApp, verbatim. Never dropped, even when the
  /// parser understood every field.
  TextColumn get rawMessage => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  /// Set when the job entered [JobStatus.ready], cleared when it leaves.
  /// Drives the "sitting in ready for N days" nudge.
  DateTimeColumn get readyAt => dateTime().nullable()();
}

/// Cloth / garment photos attached to a job (order).
///
/// Files live under the app documents directory; [relativePath] is the path
/// relative to that root so the store survives app-directory moves in tests.
class JobPhotos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get jobId =>
      integer().references(Jobs, #id, onDelete: KeyAction.cascade)();

  /// Path relative to the cloth-photos root, e.g. `42/1712345678901.jpg`.
  TextColumn get relativePath => text()();
  DateTimeColumn get createdAt => dateTime()();
}

class Appointments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get jobId =>
      integer().references(Jobs, #id, onDelete: KeyAction.cascade)();
  TextColumn get type => textEnum<AppointmentType>()();

  /// Stored as a UTC instant; always rendered and scheduled through the shop
  /// timezone so a device clock or timezone change cannot drift it.
  DateTimeColumn get scheduledAt => dateTime()();
  IntColumn get durationMinutes => integer().withDefault(const Constant(15))();
  TextColumn get status => textEnum<AppointmentStatus>()();

  /// Encoded `ReminderRule` list. Null means "use the Settings defaults".
  TextColumn get reminderRules => text().nullable()();
  TextColumn get notes => text().nullable()();
}

class BlockedDates extends Table {
  /// Local calendar day as `YYYY-MM-DD` — a blocked day is a day in the shop's
  /// own calendar, not an instant, so it must not be stored as a timestamp.
  TextColumn get day => text().withLength(min: 10, max: 10)();
  TextColumn get reason => text().nullable()();

  @override
  Set<Column> get primaryKey => {day};
}

/// Single-row settings table (`id` is always 0).
class AppSettings extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();
  TextColumn get defaultReminderRules => text()();
  TextColumn get workingHours => text()();
  IntColumn get slotMinutes => integer().withDefault(const Constant(30))();
  IntColumn get defaultTurnaroundDays => integer().withDefault(const Constant(3))();

  /// Daily agenda notification time, minutes from local midnight.
  IntColumn get dailyAgendaMinutes => integer().withDefault(const Constant(9 * 60))();
  BoolColumn get dailyAgendaEnabled => boolean().withDefault(const Constant(true))();

  /// `en`, `zh`, `ms`, or `system`.
  TextColumn get languageCode => text().withDefault(const Constant('system'))();

  /// Nudge when a job has been `ready` this many days.
  IntColumn get readyNudgeDays => integer().withDefault(const Constant(3))();
  BoolColumn get overdueNudgesEnabled => boolean().withDefault(const Constant(true))();

  /// WhatsApp reply templates, `{lang: {templateKey: body}}`.
  TextColumn get templates => text()();

  /// One-time Doze / OEM battery-optimisation explainer.
  BoolColumn get batteryExplainerSeen => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// The app's own ledger of what it has asked the OS to show.
///
/// The row id *is* the platform notification id, so cancelling is exact and a
/// reschedule can never leave an orphan behind. [registered] is false for rows
/// that are planned but deliberately not handed to the OS yet — iOS caps a app
/// at 64 pending notifications, so only the earliest slice is registered and
/// the rest are topped up on the next app open.
class PendingNotifications extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get appointmentId => integer().nullable()();
  IntColumn get jobId => integer().nullable()();

  /// `reminder` | `agenda` | `overdueCollection` | `readyNudge`.
  TextColumn get kind => text()();

  /// Stable identity for one planned notification, used to diff a rebuild
  /// against what is already scheduled.
  TextColumn get dedupeKey => text().unique()();
  DateTimeColumn get fireAt => dateTime()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  TextColumn get payload => text().nullable()();
  BoolColumn get registered => boolean().withDefault(const Constant(false))();
}

/// Fingerprints of messages already imported, so the on-resume clipboard banner
/// does not offer the same request twice.
class ImportedMessages extends Table {
  TextColumn get fingerprint => text()();
  DateTimeColumn get importedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {fingerprint};
}
