import 'package:anacoo_tailor/data/database.dart';
import 'package:anacoo_tailor/data/enums.dart';
import 'package:anacoo_tailor/domain/notification_plan.dart';
import 'package:anacoo_tailor/domain/notification_strings.dart';
import 'package:anacoo_tailor/domain/reminder_rule.dart';
import 'package:anacoo_tailor/domain/shop_time.dart';
import 'package:anacoo_tailor/services/notification_scheduler.dart';
import 'package:anacoo_tailor/services/notification_service.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/timezone.dart' as tz;

/// Stands in for the OS notification centre, remembering exactly what is
/// pending so a test can assert that nothing was left behind.
class FakeNotificationSink implements NotificationSink {
  FakeNotificationSink({this.maxPending = 60, this.exactAlarms = true});

  final int maxPending;
  final bool exactAlarms;

  final Map<int, PlannedNotification> scheduled = {};
  int scheduleCalls = 0;
  int cancelCalls = 0;

  @override
  Future<NotificationCapabilities> capabilities() async => NotificationCapabilities(
        notificationsAllowed: true,
        exactAlarmsAllowed: exactAlarms,
        maxPending: maxPending,
      );

  @override
  Future<void> schedule({
    required int id,
    required PlannedNotification notification,
    required bool useExactAlarms,
  }) async {
    scheduleCalls++;
    scheduled[id] = notification;
  }

  @override
  Future<void> cancel(int id) async {
    cancelCalls++;
    scheduled.remove(id);
  }

  @override
  Future<void> cancelAll() async => scheduled.clear();
}

void main() {
  initShopTime();

  late AppDatabase db;
  late FakeNotificationSink sink;
  late NotificationScheduler scheduler;

  /// A Monday at 10:00 shop time.
  final tz.TZDateTime now = shopDateTime(2026, 8, 3, 10, 0);

  setUp(() async {
    db = AppDatabase.memory();
    await db.loadSettings();
    sink = FakeNotificationSink();
    scheduler = NotificationScheduler(db: db, sink: sink);
  });

  tearDown(() async => db.close());

  Future<int> seedJob({required tz.TZDateTime dropOffAt}) async {
    final customerId = await db.upsertCustomer(
      CustomersCompanion.insert(
        name: 'Siti',
        createdAt: DateTime.utc(2026, 8, 1),
        phone: const Value('+60123456789'),
      ),
    );
    final jobId = await db.insertJob(
      JobsCompanion.insert(
        customerId: customerId,
        service: ServiceType.pantsJeansShortening,
        status: JobStatus.confirmed,
        createdAt: DateTime.utc(2026, 8, 1),
      ),
    );
    await db.upsertAppointment(
      AppointmentsCompanion.insert(
        jobId: jobId,
        type: AppointmentType.dropOff,
        scheduledAt: dropOffAt.toUtc(),
        status: AppointmentStatus.confirmed,
      ),
    );
    return jobId;
  }

  /// The invariant the whole design exists to protect.
  Future<void> expectLedgerAndSinkAgree() async {
    final rows = await db.allPending();
    final registeredIds =
        rows.where((r) => r.registered).map((r) => r.id).toSet();
    expect(
      sink.scheduled.keys.toSet(),
      registeredIds,
      reason: 'the OS holds exactly the notifications the ledger says it holds',
    );
  }

  group('schedule → reschedule → cancel', () {
    test('leaves zero pending notifications', () async {
      final jobId = await seedJob(dropOffAt: shopDateTime(2026, 8, 6, 12, 0));

      // Schedule.
      await scheduler.rebuild(now: now);
      expect(sink.scheduled, isNotEmpty);
      await expectLedgerAndSinkAgree();
      final firstIds = sink.scheduled.keys.toSet();

      // Reschedule to a different day.
      final appointment = await db.appointmentOf(jobId, AppointmentType.dropOff);
      await db.upsertAppointment(
        AppointmentsCompanion.insert(
          jobId: jobId,
          type: AppointmentType.dropOff,
          scheduledAt: shopDateTime(2026, 8, 9, 15, 0).toUtc(),
          status: AppointmentStatus.confirmed,
        ),
      );
      await scheduler.rebuild(now: now);
      await expectLedgerAndSinkAgree();

      // Every reminder now points at the new time — none of the old ones
      // survived under a stale id.
      for (final planned in sink.scheduled.values) {
        if (planned.kind != NotificationKind.reminder) continue;
        expect(planned.appointmentId, appointment!.id);
        expect(
          planned.fireAt.isBefore(shopDateTime(2026, 8, 9, 15, 0)),
          isTrue,
        );
        expect(planned.fireAt.isAfter(shopDateTime(2026, 8, 6, 12, 0)), isTrue);
      }
      expect(
        sink.scheduled.keys.toSet().intersection(firstIds).length <
            firstIds.length,
        isTrue,
        reason: 'at least one stale notification was cancelled',
      );

      // Cancel.
      await db.deleteJob(jobId);
      await scheduler.rebuild(now: now);

      expect(sink.scheduled, isEmpty);
      expect(await db.allPending(), isEmpty);
    });

    test('cancelling only the appointment also clears its reminders', () async {
      final jobId = await seedJob(dropOffAt: shopDateTime(2026, 8, 6, 12, 0));
      await scheduler.rebuild(now: now);
      expect(sink.scheduled, isNotEmpty);

      final appointment = await db.appointmentOf(jobId, AppointmentType.dropOff);
      await db.upsertAppointment(
        AppointmentsCompanion.insert(
          jobId: jobId,
          type: AppointmentType.dropOff,
          scheduledAt: appointment!.scheduledAt,
          status: AppointmentStatus.cancelled,
        ),
      );
      await scheduler.rebuild(now: now);

      expect(sink.scheduled, isEmpty);
      expect(await db.allPending(), isEmpty);
    });

    test('an unchanged appointment is not re-armed on every rebuild', () async {
      await seedJob(dropOffAt: shopDateTime(2026, 8, 6, 12, 0));
      await scheduler.rebuild(now: now);
      final callsAfterFirst = sink.scheduleCalls;

      await scheduler.rebuild(now: now);

      expect(sink.scheduleCalls, callsAfterFirst);
      await expectLedgerAndSinkAgree();
    });

    test('cancelEverything empties both the OS and the ledger', () async {
      await seedJob(dropOffAt: shopDateTime(2026, 8, 6, 12, 0));
      await scheduler.rebuild(now: now);
      expect(sink.scheduled, isNotEmpty);

      await scheduler.cancelEverything();

      expect(sink.scheduled, isEmpty);
      expect(await db.allPending(), isEmpty);
    });
  });

  group('platform pending limit', () {
    test('registers only the earliest slice and holds the rest back', () async {
      sink = FakeNotificationSink(maxPending: 3);
      scheduler = NotificationScheduler(db: db, sink: sink);

      for (var day = 5; day < 12; day++) {
        await seedJob(dropOffAt: shopDateTime(2026, 8, day, 12, 0));
      }
      await scheduler.rebuild(now: now);

      expect(sink.scheduled.length, 3);
      final rows = await db.allPending();
      expect(rows.length, greaterThan(3));
      await expectLedgerAndSinkAgree();

      // The three that made it are the three that fire first.
      final registered = rows.where((r) => r.registered).toList();
      final deferred = rows.where((r) => !r.registered).toList();
      final latestRegistered =
          registered.map((r) => r.fireAt).reduce((a, b) => a.isAfter(b) ? a : b);
      final earliestDeferred =
          deferred.map((r) => r.fireAt).reduce((a, b) => a.isBefore(b) ? a : b);
      expect(latestRegistered.isAfter(earliestDeferred), isFalse);
    });
  });

  group('planner', () {
    final strings = const NotificationStrings('en');

    ScheduleSubject subjectAt(tz.TZDateTime at, {int id = 1}) => ScheduleSubject(
          appointmentId: id,
          jobId: id,
          type: AppointmentType.dropOff,
          scheduledAtUtc: at.toUtc(),
          status: AppointmentStatus.confirmed,
          jobStatus: JobStatus.confirmed,
          customerName: 'Siti',
          service: ServiceType.pantsJeansShortening,
        );

    test('the default rules mean 9 PM the evening before, and one hour before',
        () {
      final at = shopDateTime(2026, 8, 6, 12, 0);
      final plan = planNotifications(
        now: now,
        appointments: [subjectAt(at)],
        readyJobs: const [],
        defaultRules: ReminderRule.defaults,
        strings: strings,
        dailyAgendaMinutes: 9 * 60,
        dailyAgendaEnabled: false,
      );

      final fireTimes = plan.map((p) => p.fireAt).toList();
      expect(fireTimes, contains(shopDateTime(2026, 8, 5, 21, 0)));
      expect(fireTimes, contains(shopDateTime(2026, 8, 6, 11, 0)));
    });

    test('a 9 PM appointment still gets its nudge the evening before', () {
      final at = shopDateTime(2026, 8, 6, 21, 0);
      final plan = planNotifications(
        now: now,
        appointments: [subjectAt(at)],
        readyJobs: const [],
        defaultRules: ReminderRule.defaults,
        strings: strings,
        dailyAgendaMinutes: 9 * 60,
        dailyAgendaEnabled: false,
      );

      expect(
        plan.map((p) => p.fireAt),
        contains(shopDateTime(2026, 8, 5, 21, 0)),
      );
    });

    test('reminders already in the past are never scheduled', () {
      final at = shopDateTime(2026, 8, 3, 10, 30);
      final plan = planNotifications(
        now: now,
        appointments: [subjectAt(at)],
        readyJobs: const [],
        defaultRules: ReminderRule.defaults,
        strings: strings,
        dailyAgendaMinutes: 9 * 60,
        dailyAgendaEnabled: false,
      );

      expect(plan, isEmpty);
    });

    test('the daily agenda counts drop-offs and collections', () {
      final plan = planNotifications(
        now: now,
        appointments: [
          subjectAt(shopDateTime(2026, 8, 6, 12, 0), id: 1),
          subjectAt(shopDateTime(2026, 8, 6, 13, 0), id: 2),
          ScheduleSubject(
            appointmentId: 3,
            jobId: 3,
            type: AppointmentType.collection,
            scheduledAtUtc: shopDateTime(2026, 8, 6, 17, 0).toUtc(),
            status: AppointmentStatus.confirmed,
            jobStatus: JobStatus.ready,
            customerName: 'Ah Meng',
            service: ServiceType.basicAlterations,
          ),
        ],
        readyJobs: const [],
        defaultRules: const [],
        strings: strings,
        dailyAgendaMinutes: 9 * 60,
      );

      final agenda = plan.firstWhere((p) => p.kind == NotificationKind.agenda);
      expect(agenda.fireAt, shopDateTime(2026, 8, 6, 9, 0));
      expect(agenda.body, 'Today: 2 drop-offs, 1 collection.');
    });

    test('quiet days get no agenda notification', () {
      final plan = planNotifications(
        now: now,
        appointments: [subjectAt(shopDateTime(2026, 8, 6, 12, 0))],
        readyJobs: const [],
        defaultRules: const [],
        strings: strings,
        dailyAgendaMinutes: 9 * 60,
      );

      final agendaDays = plan
          .where((p) => p.kind == NotificationKind.agenda)
          .map((p) => p.dedupeKey)
          .toList();
      expect(agendaDays, ['agenda:2026-08-06']);
    });

    test('an overdue collection is nudged at the next agenda time', () {
      final plan = planNotifications(
        now: now,
        appointments: [
          ScheduleSubject(
            appointmentId: 9,
            jobId: 9,
            type: AppointmentType.collection,
            scheduledAtUtc: shopDateTime(2026, 7, 30, 17, 0).toUtc(),
            status: AppointmentStatus.confirmed,
            jobStatus: JobStatus.ready,
            customerName: 'Ah Meng',
            service: ServiceType.basicAlterations,
          ),
        ],
        readyJobs: const [],
        defaultRules: const [],
        strings: strings,
        dailyAgendaMinutes: 9 * 60,
      );

      final overdue =
          plan.firstWhere((p) => p.kind == NotificationKind.overdueCollection);
      // 09:00 today has already passed at 10:00, so it lands tomorrow.
      expect(overdue.fireAt, shopDateTime(2026, 8, 4, 9, 0));
      expect(overdue.body, contains('4 days ago'));
    });

    test('a job parked in ready is nudged after the configured delay', () {
      final plan = planNotifications(
        now: now,
        appointments: const [],
        readyJobs: [
          ReadySubject(
            jobId: 4,
            customerName: 'Nurul',
            readyAtUtc: shopDateTime(2026, 8, 2, 16, 0).toUtc(),
          ),
        ],
        defaultRules: const [],
        strings: strings,
        dailyAgendaMinutes: 9 * 60,
        readyNudgeDays: 3,
      );

      final nudge = plan.single;
      expect(nudge.kind, NotificationKind.readyNudge);
      expect(nudge.fireAt, shopDateTime(2026, 8, 5, 9, 0));
      expect(nudge.body, contains('3 days'));
    });

    test('a cancelled job contributes nothing', () {
      final plan = planNotifications(
        now: now,
        appointments: [
          ScheduleSubject(
            appointmentId: 1,
            jobId: 1,
            type: AppointmentType.dropOff,
            scheduledAtUtc: shopDateTime(2026, 8, 6, 12, 0).toUtc(),
            status: AppointmentStatus.confirmed,
            jobStatus: JobStatus.cancelled,
            customerName: 'Siti',
            service: ServiceType.basicAlterations,
          ),
        ],
        readyJobs: const [],
        defaultRules: ReminderRule.defaults,
        strings: strings,
        dailyAgendaMinutes: 9 * 60,
      );

      expect(plan, isEmpty);
    });

    test('the plan is stable — rebuilding produces identical dedupe keys', () {
      List<String> keys() => planNotifications(
            now: now,
            appointments: [subjectAt(shopDateTime(2026, 8, 6, 12, 0))],
            readyJobs: const [],
            defaultRules: ReminderRule.defaults,
            strings: strings,
            dailyAgendaMinutes: 9 * 60,
          ).map((p) => p.dedupeKey).toList();

      expect(keys(), keys());
    });
  });

  group('reminder rules', () {
    test('survive an encode/decode round trip', () {
      for (final rule in ReminderRule.defaults) {
        expect(ReminderRule.decode(rule.encode()), rule);
      }
      expect(
        ReminderRule.decodeList(ReminderRule.encodeList(ReminderRule.defaults)),
        ReminderRule.defaults,
      );
    });

    test('garbage decodes to nothing rather than throwing', () {
      expect(ReminderRule.decode('not-a-rule'), isNull);
      expect(ReminderRule.decodeList('before:xx,dayBefore:1@25:00'), isEmpty);
    });
  });
}
