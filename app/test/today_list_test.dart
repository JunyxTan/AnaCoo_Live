import 'dart:io';

import 'package:anacoo_tailor/data/database.dart';
import 'package:anacoo_tailor/data/enums.dart';
import 'package:anacoo_tailor/data/job_repository.dart';
import 'package:anacoo_tailor/domain/appointment_list_query.dart';
import 'package:anacoo_tailor/domain/notification_plan.dart';
import 'package:anacoo_tailor/domain/shop_time.dart';
import 'package:anacoo_tailor/l10n/app_strings.dart';
import 'package:anacoo_tailor/services/cloth_photo_store.dart';
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
      photos: ClothPhotoStore(root: Directory.systemTemp.createTempSync('photos')),
    );
  });

  tearDown(() async => db.close());

  Future<AppointmentEntry> saveNamed({
    required String name,
    required tz.TZDateTime at,
    AppointmentType type = AppointmentType.dropOff,
    bool rush = false,
  }) async {
    final earlier =
        shopDateTime(at.year, at.month, at.day - 2, at.hour, at.minute);
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

  group('AppStrings list labels', () {
    test('cover every filter and sort in all three languages', () {
      for (final language in ['en', 'zh', 'ms']) {
        final strings = AppStrings(language);
        for (final filter in AppointmentFilter.values) {
          expect(strings.appointmentFilterLabel(filter), isNotEmpty);
        }
        for (final sort in AppointmentSort.values) {
          expect(strings.appointmentSortLabel(sort), isNotEmpty);
        }
        expect(strings.tabAppointments, isNotEmpty);
        expect(strings.appointments, isNotEmpty);
        expect(strings.noAppointments, isNotEmpty);
      }
    });
  });

  group('buildAppointmentItems all-time list', () {
    test('lists appointments across different days', () async {
      final past = await saveNamed(
        name: 'Amina',
        at: shopDateTime(2026, 8, 1, 11, 0),
      );
      final future = await saveNamed(
        name: 'Budi',
        at: shopDateTime(2026, 8, 20, 14, 0),
        type: AppointmentType.collection,
      );

      final items = buildAppointmentItems(
        entries: [past, future],
        filter: AppointmentFilter.all,
        sort: AppointmentSort.timeAsc,
      );

      expect(items.map((e) => e.customer.name), ['Amina', 'Budi']);
    });

    test('filters by type, rush, and overdue', () async {
      final pastRush = await saveNamed(
        name: 'Zara',
        at: shopDateTime(2026, 7, 1, 11, 0),
        rush: true,
      );
      final upcoming = await saveNamed(
        name: 'Amina',
        at: shopDateTime(2026, 12, 1, 11, 0),
        type: AppointmentType.collection,
      );
      final nowUtc = shopDateTime(2026, 8, 10, 12, 0).toUtc();

      expect(
        buildAppointmentItems(
          entries: [pastRush, upcoming],
          filter: AppointmentFilter.dropOff,
          sort: AppointmentSort.timeAsc,
          nowUtc: nowUtc,
        ).map((e) => e.customer.name),
        ['Zara'],
      );
      expect(
        buildAppointmentItems(
          entries: [pastRush, upcoming],
          filter: AppointmentFilter.rush,
          sort: AppointmentSort.timeAsc,
          nowUtc: nowUtc,
        ).map((e) => e.customer.name),
        ['Zara'],
      );
      expect(
        buildAppointmentItems(
          entries: [pastRush, upcoming],
          filter: AppointmentFilter.overdue,
          sort: AppointmentSort.timeAsc,
          nowUtc: nowUtc,
        ).map((e) => e.customer.name),
        ['Zara'],
      );
    });

    test('sorts by name and time', () async {
      final late = await saveNamed(
        name: 'Zara',
        at: shopDateTime(2026, 8, 20, 16, 0),
        rush: true,
      );
      final early = await saveNamed(
        name: 'Amina',
        at: shopDateTime(2026, 8, 1, 11, 0),
      );

      expect(
        buildAppointmentItems(
          entries: [late, early],
          filter: AppointmentFilter.all,
          sort: AppointmentSort.name,
        ).map((e) => e.customer.name),
        ['Amina', 'Zara'],
      );
      expect(
        buildAppointmentItems(
          entries: [late, early],
          filter: AppointmentFilter.all,
          sort: AppointmentSort.timeDesc,
        ).map((e) => e.customer.name),
        ['Zara', 'Amina'],
      );
      expect(
        buildAppointmentItems(
          entries: [late, early],
          filter: AppointmentFilter.all,
          sort: AppointmentSort.rushFirst,
        ).map((e) => e.customer.name),
        ['Zara', 'Amina'],
      );
    });
  });

  group('buildDayAppointmentItems', () {
    test('filters and sorts a day agenda', () async {
      final dropOff = await saveNamed(
        name: 'Zara',
        at: shopDateTime(2026, 8, 10, 16, 0),
        rush: true,
      );
      final collection = await saveNamed(
        name: 'Amina',
        at: shopDateTime(2026, 8, 10, 11, 0),
        type: AppointmentType.collection,
      );

      final dropOffs = buildDayAppointmentItems(
        entries: [dropOff, collection],
        filter: AppointmentFilter.dropOff,
        sort: AppointmentSort.timeAsc,
      );
      final byName = buildDayAppointmentItems(
        entries: [dropOff, collection],
        filter: AppointmentFilter.all,
        sort: AppointmentSort.name,
      );

      expect(dropOffs.map((e) => e.customer.name), ['Zara']);
      expect(byName.map((e) => e.customer.name), ['Amina', 'Zara']);
    });
  });
}
