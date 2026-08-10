import 'package:anacoo_tailor/data/database.dart';
import 'package:anacoo_tailor/data/enums.dart';
import 'package:anacoo_tailor/data/job_repository.dart';
import 'package:anacoo_tailor/domain/notification_plan.dart';
import 'package:anacoo_tailor/domain/shop_time.dart';
import 'package:anacoo_tailor/domain/today_list.dart';
import 'package:anacoo_tailor/services/notification_scheduler.dart';
import 'package:anacoo_tailor/services/notification_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/timezone.dart' as tz;

class _SilentSink implements NotificationSink {
  @override
  Future<NotificationCapabilities> capabilities() async =>
      const NotificationCapabilities(
        notificationsAllowed: true,
        exactAlarmsAllowed: true,
        maxPending: 64,
      );

  @override
  Future<void> schedule({
    required int id,
    required PlannedNotification notification,
    required bool useExactAlarms,
  }) async {}

  @override
  Future<void> cancel(int id) async {}

  @override
  Future<void> cancelAll() async {}
}

void main() {
  initShopTime();

  late AppDatabase db;
  late JobRepository repository;

  setUp(() async {
    db = AppDatabase.memory();
    await db.loadSettings();
    repository = JobRepository(
      db: db,
      scheduler: NotificationScheduler(db: db, sink: _SilentSink()),
    );
  });

  tearDown(() async => db.close());

  Future<AppointmentEntry> saveNamed({
    required String name,
    required tz.TZDateTime at,
    AppointmentType type = AppointmentType.dropOff,
    bool rush = false,
  }) async {
    final earlier = shopDateTime(at.year, at.month, at.day - 2, at.hour, at.minute);
    final jobId = await repository.save(
      JobDraft(
        customerName: name,
        phone: '0120000000',
        service: ServiceType.basicAlterations,
        isRush: rush,
        dropOff: AppointmentDraft(
          at: type == AppointmentType.dropOff ? at : earlier,
        ),
        collection: type == AppointmentType.collection
            ? AppointmentDraft(at: at)
            : null,
      ),
    );
    final entries = await db.appointmentsBetween(
      at.subtract(const Duration(hours: 1)).toUtc(),
      at.add(const Duration(hours: 1)).toUtc(),
    );
    return entries.firstWhere(
      (e) => e.job.id == jobId && e.appointment.type == type,
    );
  }

  group('buildTodayItems', () {
    test('lists today appointments instead of staying empty', () async {
      final first = await saveNamed(
        name: 'Amina',
        at: shopDateTime(2026, 8, 10, 11, 0),
      );
      final second = await saveNamed(
        name: 'Budi',
        at: shopDateTime(2026, 8, 10, 14, 0),
        type: AppointmentType.collection,
      );

      final items = buildTodayItems(
        today: [first, second],
        overdue: const [],
        ready: const [],
        filter: TodayFilter.all,
        sort: TodaySort.timeAsc,
      );

      expect(items, hasLength(2));
      expect(items.map((e) => e.customerName), ['Amina', 'Budi']);
    });

    test('filters by appointment type', () async {
      final dropOff = await saveNamed(
        name: 'Amina',
        at: shopDateTime(2026, 8, 10, 11, 0),
      );
      final collection = await saveNamed(
        name: 'Budi',
        at: shopDateTime(2026, 8, 10, 14, 0),
        type: AppointmentType.collection,
      );

      final dropOffs = buildTodayItems(
        today: [dropOff, collection],
        overdue: const [],
        ready: const [],
        filter: TodayFilter.dropOff,
        sort: TodaySort.timeAsc,
      );
      final collections = buildTodayItems(
        today: [dropOff, collection],
        overdue: const [],
        ready: const [],
        filter: TodayFilter.collection,
        sort: TodaySort.timeAsc,
      );

      expect(dropOffs.map((e) => e.customerName), ['Amina']);
      expect(collections.map((e) => e.customerName), ['Budi']);
    });

    test('sorts by name and rush-first', () async {
      final lateRush = await saveNamed(
        name: 'Zara',
        at: shopDateTime(2026, 8, 10, 16, 0),
        rush: true,
      );
      final early = await saveNamed(
        name: 'Amina',
        at: shopDateTime(2026, 8, 10, 11, 0),
      );

      final byName = buildTodayItems(
        today: [lateRush, early],
        overdue: const [],
        ready: const [],
        filter: TodayFilter.all,
        sort: TodaySort.name,
      );
      final rushFirst = buildTodayItems(
        today: [lateRush, early],
        overdue: const [],
        ready: const [],
        filter: TodayFilter.all,
        sort: TodaySort.rushFirst,
      );
      final timeDesc = buildTodayItems(
        today: [lateRush, early],
        overdue: const [],
        ready: const [],
        filter: TodayFilter.all,
        sort: TodaySort.timeDesc,
      );

      expect(byName.map((e) => e.customerName), ['Amina', 'Zara']);
      expect(rushFirst.map((e) => e.customerName), ['Zara', 'Amina']);
      expect(timeDesc.map((e) => e.customerName), ['Zara', 'Amina']);
    });

    test('dedupes overdue entries that also appear in today', () async {
      final entry = await saveNamed(
        name: 'Late',
        at: shopDateTime(2026, 8, 10, 9, 0),
      );

      final items = buildTodayItems(
        today: [entry],
        overdue: [entry],
        ready: const [],
        filter: TodayFilter.all,
        sort: TodaySort.timeAsc,
      );

      expect(items, hasLength(1));
      expect((items.single as TodayAppointmentItem).isOverdue, isTrue);
    });
  });
}
