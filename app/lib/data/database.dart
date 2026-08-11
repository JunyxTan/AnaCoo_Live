import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import '../domain/message_templates.dart';
import '../domain/reminder_rule.dart';
import '../domain/working_hours.dart';
import 'enums.dart';
import 'tables.dart';

part 'database.g.dart';

/// One drop-off + one collection joined to their job and customer.
class JobBundle {
  const JobBundle({
    required this.job,
    required this.customer,
    required this.dropOff,
    required this.collection,
  });

  final Job job;
  final Customer customer;
  final Appointment? dropOff;
  final Appointment? collection;

  Appointment? appointmentOfType(AppointmentType type) =>
      type == AppointmentType.dropOff ? dropOff : collection;
}

/// An appointment with just enough context to render an agenda row.
class AppointmentEntry {
  const AppointmentEntry({
    required this.appointment,
    required this.job,
    required this.customer,
  });

  final Appointment appointment;
  final Job job;
  final Customer customer;
}

@DriftDatabase(
  tables: [
    Customers,
    Jobs,
    Appointments,
    JobPhotos,
    BlockedDates,
    AppSettings,
    PendingNotifications,
    ImportedMessages,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// In-memory database for tests.
  AppDatabase.memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedSettings();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // Collapse the six-step pipeline. `received` survives as itself — the
        // step is back, meaning the same thing it always did — so only the
        // names with no home left are rewritten.
        await customStatement('''
UPDATE jobs SET status = CASE status
  WHEN 'requested' THEN 'booked'
  WHEN 'confirmed' THEN 'booked'
  WHEN 'inProgress' THEN 'sewing'
  WHEN 'collected' THEN 'done'
  ELSE status
END
''');
      }
      if (from < 3) {
        await m.createTable(jobPhotos);
      }
      if (from < 4) {
        await m.addColumn(customers, customers.archivedAt);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      if (details.wasCreated) return;
      await _seedSettings();
    },
  );

  Future<void> _seedSettings() async {
    await into(appSettings).insert(
      AppSettingsCompanion.insert(
        // Explicit: `id INTEGER PRIMARY KEY` is a rowid alias in SQLite, so the
        // column default of 0 is ignored and the row would land at id 1.
        id: const Value(0),
        defaultReminderRules: ReminderRule.encodeList(ReminderRule.defaults),
        workingHours: WorkingHours.anacooDefault.encode(),
        templates: MessageTemplates.defaults.encode(),
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  // ---------------------------------------------------------------- settings

  Stream<AppSetting> watchSettings() =>
      (select(appSettings)..where((t) => t.id.equals(0))).watchSingle();

  Future<AppSetting> loadSettings() async {
    await _seedSettings();
    return (select(appSettings)..where((t) => t.id.equals(0))).getSingle();
  }

  Future<void> saveSettings(AppSettingsCompanion patch) =>
      (update(appSettings)..where((t) => t.id.equals(0))).write(patch);

  // --------------------------------------------------------------- customers

  /// The customer directory, name-ordered.
  ///
  /// Archived customers are a separate list rather than a flag on the rows:
  /// every caller wants one side or the other, and the directory asking for
  /// "customers" should never have to remember to exclude them.
  Stream<List<Customer>> watchCustomers({
    String query = '',
    bool archived = false,
  }) {
    final q = select(customers)
      ..where((t) => archived ? t.archivedAt.isNotNull() : t.archivedAt.isNull())
      ..orderBy([(t) => OrderingTerm(expression: t.name)]);
    final needle = query.trim();
    if (needle.isNotEmpty) {
      final like = '%${needle.toLowerCase()}%';
      q.where(
        (t) =>
            t.name.lower().like(like) |
            t.phone.lower().like(like) |
            t.whatsappNumber.lower().like(like),
      );
    }
    return q.watch();
  }

  /// Hides a customer from the directory, or puts them back.
  Future<void> setCustomerArchived(
    int id,
    bool archived, {
    DateTime? now,
  }) =>
      (update(customers)..where((t) => t.id.equals(id))).write(
        CustomersCompanion(
          archivedAt: Value(archived ? (now ?? DateTime.now()).toUtc() : null),
        ),
      );

  Future<Customer?> findCustomerByPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return Future.value(null);
    return (select(customers)
          ..where((t) => t.phone.equals(phone) | t.whatsappNumber.equals(phone))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<Customer> getCustomer(int id) =>
      (select(customers)..where((t) => t.id.equals(id))).getSingle();

  Future<int> upsertCustomer(CustomersCompanion value) async {
    if (value.id.present) {
      await (update(customers)..where((t) => t.id.equals(value.id.value)))
          .write(value);
      return value.id.value;
    }
    return into(customers).insert(value);
  }

  /// Jobs count per customer, for the repeat-customer flag.
  Future<Map<int, int>> jobCountsByCustomer() async {
    final count = jobs.id.count();
    final rows = await (selectOnly(jobs)
          ..addColumns([jobs.customerId, count])
          ..groupBy([jobs.customerId]))
        .get();
    return {
      for (final row in rows)
        row.read(jobs.customerId)!: row.read(count) ?? 0,
    };
  }

  // -------------------------------------------------------------------- jobs

  Future<Job> getJob(int id) =>
      (select(jobs)..where((t) => t.id.equals(id))).getSingle();

  Stream<JobBundle?> watchJobBundle(int jobId) {
    final jobStream = (select(jobs)..where((t) => t.id.equals(jobId))).watchSingleOrNull();
    return jobStream.asyncMap((job) async {
      if (job == null) return null;
      return _bundleFor(job);
    });
  }

  Future<JobBundle> _bundleFor(Job job) async {
    final customer = await getCustomer(job.customerId);
    final appts = await (select(appointments)
          ..where((t) => t.jobId.equals(job.id)))
        .get();
    return JobBundle(
      job: job,
      customer: customer,
      dropOff: appts.where((a) => a.type == AppointmentType.dropOff).firstOrNull,
      collection:
          appts.where((a) => a.type == AppointmentType.collection).firstOrNull,
    );
  }

  Stream<List<JobBundle>> watchJobsForCustomer(int customerId) {
    final q = select(jobs)
      ..where((t) => t.customerId.equals(customerId))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return q.watch().asyncMap(
      (rows) => Future.wait(rows.map(_bundleFor)),
    );
  }

  /// Jobs parked in `ready` — the pickup shelf on the Today screen.
  Stream<List<JobBundle>> watchReadyJobs() {
    final q = select(jobs)
      ..where((t) => t.status.equalsValue(JobStatus.ready))
      ..orderBy([(t) => OrderingTerm(expression: t.readyAt)]);
    return q.watch().asyncMap((rows) => Future.wait(rows.map(_bundleFor)));
  }

  Future<List<Job>> readyJobsOlderThan(DateTime cutoffUtc) => (select(jobs)
        ..where(
          (t) =>
              t.status.equalsValue(JobStatus.ready) &
              t.readyAt.isSmallerThanValue(cutoffUtc),
        ))
      .get();

  Future<int> insertJob(JobsCompanion value) => into(jobs).insert(value);

  Future<void> updateJob(int id, JobsCompanion patch) =>
      (update(jobs)..where((t) => t.id.equals(id))).write(patch);

  /// Moves a job along the pipeline, keeping [Jobs.readyAt] in step.
  Future<void> setJobStatus(int id, JobStatus status, {DateTime? now}) async {
    final at = (now ?? DateTime.now()).toUtc();
    await updateJob(
      id,
      JobsCompanion(
        status: Value(status),
        readyAt: status == JobStatus.ready
            ? Value(at)
            : const Value(null),
      ),
    );
  }

  Future<void> deleteJob(int id) async {
    await (delete(jobPhotos)..where((t) => t.jobId.equals(id))).go();
    await (delete(appointments)..where((t) => t.jobId.equals(id))).go();
    await (delete(jobs)..where((t) => t.id.equals(id))).go();
  }

  // -------------------------------------------------------------- job photos

  Stream<List<JobPhoto>> watchJobPhotos(int jobId) => (select(jobPhotos)
        ..where((t) => t.jobId.equals(jobId))
        ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
      .watch();

  Future<List<JobPhoto>> photosForJob(int jobId) => (select(jobPhotos)
        ..where((t) => t.jobId.equals(jobId))
        ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
      .get();

  Future<JobPhoto> getJobPhoto(int id) =>
      (select(jobPhotos)..where((t) => t.id.equals(id))).getSingle();

  Future<int> insertJobPhoto(JobPhotosCompanion value) =>
      into(jobPhotos).insert(value);

  Future<void> deleteJobPhoto(int id) =>
      (delete(jobPhotos)..where((t) => t.id.equals(id))).go();

  // ------------------------------------------------------------ appointments

  Future<Appointment?> appointmentOf(int jobId, AppointmentType type) =>
      (select(appointments)
            ..where((t) => t.jobId.equals(jobId) & t.type.equalsValue(type))
            ..limit(1))
          .getSingleOrNull();

  /// Insert-or-update keyed on `(jobId, type)` — a job has at most one
  /// appointment of each type.
  Future<int> upsertAppointment(AppointmentsCompanion value) async {
    final existing = await appointmentOf(value.jobId.value, value.type.value);
    if (existing == null) return into(appointments).insert(value);
    await (update(appointments)..where((t) => t.id.equals(existing.id)))
        .write(value);
    return existing.id;
  }

  Future<void> deleteAppointment(int id) =>
      (delete(appointments)..where((t) => t.id.equals(id))).go();

  /// Every appointment with its job and customer — the input the notification
  /// planner rebuilds from.
  Future<List<AppointmentEntry>> allAppointmentEntries() async {
    final rows = await (select(appointments).join([
      innerJoin(jobs, jobs.id.equalsExp(appointments.jobId)),
      innerJoin(customers, customers.id.equalsExp(jobs.customerId)),
    ])).get();
    return rows
        .map(
          (row) => AppointmentEntry(
            appointment: row.readTable(appointments),
            job: row.readTable(jobs),
            customer: row.readTable(customers),
          ),
        )
        .toList();
  }

  /// Live view of the same, so the clash warnings in the job editor stay
  /// truthful while another change is saved underneath them.
  Stream<List<AppointmentEntry>> watchAllAppointmentEntries() {
    final query = select(appointments).join([
      innerJoin(jobs, jobs.id.equalsExp(appointments.jobId)),
      innerJoin(customers, customers.id.equalsExp(jobs.customerId)),
    ]);
    return query.watch().map(
          (rows) => rows
              .map(
                (row) => AppointmentEntry(
                  appointment: row.readTable(appointments),
                  job: row.readTable(jobs),
                  customer: row.readTable(customers),
                ),
              )
              .toList(),
        );
  }

  Future<List<({Job job, Customer customer})>> readyJobEntries() async {
    final rows = await (select(jobs).join([
      innerJoin(customers, customers.id.equalsExp(jobs.customerId)),
    ])..where(jobs.status.equalsValue(JobStatus.ready)))
        .get();
    return rows
        .map(
          (row) => (
            job: row.readTable(jobs),
            customer: row.readTable(customers),
          ),
        )
        .toList();
  }

  Future<List<Appointment>> allLiveAppointments() => (select(appointments)
        ..where(
          (t) =>
              t.status.equalsValue(AppointmentStatus.pending) |
              t.status.equalsValue(AppointmentStatus.confirmed),
        ))
      .get();

  Future<List<AppointmentEntry>> appointmentsBetween(
    DateTime fromUtc,
    DateTime toUtc,
  ) async {
    final query = select(appointments).join([
      innerJoin(jobs, jobs.id.equalsExp(appointments.jobId)),
      innerJoin(customers, customers.id.equalsExp(jobs.customerId)),
    ])
      ..where(
        appointments.scheduledAt.isBiggerOrEqualValue(fromUtc) &
            appointments.scheduledAt.isSmallerThanValue(toUtc),
      )
      ..orderBy([OrderingTerm(expression: appointments.scheduledAt)]);
    final rows = await query.get();
    return rows
        .map(
          (row) => AppointmentEntry(
            appointment: row.readTable(appointments),
            job: row.readTable(jobs),
            customer: row.readTable(customers),
          ),
        )
        .toList();
  }

  Stream<List<AppointmentEntry>> watchAppointmentsBetween(
    DateTime fromUtc,
    DateTime toUtc,
  ) {
    final query = select(appointments).join([
      innerJoin(jobs, jobs.id.equalsExp(appointments.jobId)),
      innerJoin(customers, customers.id.equalsExp(jobs.customerId)),
    ])
      ..where(
        appointments.scheduledAt.isBiggerOrEqualValue(fromUtc) &
            appointments.scheduledAt.isSmallerThanValue(toUtc),
      )
      ..orderBy([OrderingTerm(expression: appointments.scheduledAt)]);
    return query.watch().map(
          (rows) => rows
              .map(
                (row) => AppointmentEntry(
                  appointment: row.readTable(appointments),
                  job: row.readTable(jobs),
                  customer: row.readTable(customers),
                ),
              )
              .toList(),
        );
  }

  /// Live appointments whose time has passed — overdue collections and
  /// drop-offs that never got marked done.
  Stream<List<AppointmentEntry>> watchOverdue(DateTime nowUtc) {
    final query = select(appointments).join([
      innerJoin(jobs, jobs.id.equalsExp(appointments.jobId)),
      innerJoin(customers, customers.id.equalsExp(jobs.customerId)),
    ])
      ..where(
        appointments.scheduledAt.isSmallerThanValue(nowUtc) &
            (appointments.status.equalsValue(AppointmentStatus.pending) |
                appointments.status.equalsValue(AppointmentStatus.confirmed)) &
            jobs.status.isNotIn([JobStatus.done.name, JobStatus.cancelled.name]),
      )
      ..orderBy([OrderingTerm(expression: appointments.scheduledAt)]);
    return query.watch().map(
          (rows) => rows
              .map(
                (row) => AppointmentEntry(
                  appointment: row.readTable(appointments),
                  job: row.readTable(jobs),
                  customer: row.readTable(customers),
                ),
              )
              .toList(),
        );
  }

  // ----------------------------------------------------------- blocked dates

  Stream<List<BlockedDate>> watchBlockedDates() =>
      (select(blockedDates)..orderBy([(t) => OrderingTerm(expression: t.day)]))
          .watch();

  Future<List<BlockedDate>> allBlockedDates() => select(blockedDates).get();

  Future<void> blockDay(String day, String? reason) => into(blockedDates).insert(
        BlockedDatesCompanion.insert(day: day, reason: Value(reason)),
        mode: InsertMode.insertOrReplace,
      );

  Future<void> unblockDay(String day) =>
      (delete(blockedDates)..where((t) => t.day.equals(day))).go();

  // ---------------------------------------------------- imported fingerprints

  Future<bool> isMessageImported(String fingerprint) async {
    final row = await (select(importedMessages)
          ..where((t) => t.fingerprint.equals(fingerprint))
          ..limit(1))
        .getSingleOrNull();
    return row != null;
  }

  Future<void> markMessageImported(String fingerprint) =>
      into(importedMessages).insert(
        ImportedMessagesCompanion.insert(
          fingerprint: fingerprint,
          importedAt: DateTime.now().toUtc(),
        ),
        mode: InsertMode.insertOrReplace,
      );

  // --------------------------------------------------- pending notifications

  Future<List<PendingNotification>> allPending() =>
      (select(pendingNotifications)
            ..orderBy([(t) => OrderingTerm(expression: t.fireAt)]))
          .get();

  Future<int> insertPending(PendingNotificationsCompanion value) =>
      into(pendingNotifications).insert(value);

  Future<void> updatePending(
    int id, {
    required DateTime fireAt,
    required String title,
    required String body,
    required bool registered,
  }) =>
      (update(pendingNotifications)..where((t) => t.id.equals(id))).write(
        PendingNotificationsCompanion(
          fireAt: Value(fireAt),
          title: Value(title),
          body: Value(body),
          registered: Value(registered),
        ),
      );

  Future<void> markRegistered(int id, bool registered) =>
      (update(pendingNotifications)..where((t) => t.id.equals(id)))
          .write(PendingNotificationsCompanion(registered: Value(registered)));

  Future<void> deletePending(int id) =>
      (delete(pendingNotifications)..where((t) => t.id.equals(id))).go();

  Future<void> clearPending() => delete(pendingNotifications).go();
}

/// Opens the on-disk database in the app documents directory.
Future<AppDatabase> openAppDatabase() async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File(p.join(dir.path, 'anacoo_tailor.sqlite'));
  // sqlite3 3.x ships its own native library; only the temp dir needs setting
  // so that SQLite has somewhere to spill on Android.
  sqlite3.tempDirectory = (await getTemporaryDirectory()).path;
  return AppDatabase(NativeDatabase.createInBackground(file));
}
