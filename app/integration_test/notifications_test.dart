import 'dart:io';

import 'package:anacoo_tailor/data/database.dart';
import 'package:anacoo_tailor/data/enums.dart';
import 'package:anacoo_tailor/data/job_repository.dart';
import 'package:anacoo_tailor/domain/shop_time.dart';
import 'package:anacoo_tailor/services/cloth_photo_store.dart';
import 'package:anacoo_tailor/services/notification_scheduler.dart';
import 'package:anacoo_tailor/services/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// The same zero-orphan guarantee as `test/notification_scheduler_test.dart`,
/// but against the real platform notification centre.
///
/// Run on a connected device or simulator:
///   flutter test integration_test/notifications_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  initShopTime();

  late AppDatabase db;
  late NotificationService notifications;
  late NotificationScheduler scheduler;
  late JobRepository repository;

  setUp(() async {
    db = AppDatabase.memory();
    await db.loadSettings();
    notifications = NotificationService();
    await notifications.initialize();
    await notifications.requestPermissions();
    // Start from a clean slate: a previous run's notifications would otherwise
    // be counted as this run's orphans.
    await notifications.cancelAll();

    scheduler = NotificationScheduler(db: db, sink: notifications);
    repository = JobRepository(
      db: db,
      scheduler: scheduler,
      photos: ClothPhotoStore(root: Directory.systemTemp.createTempSync('photos')),
    );
  });

  tearDown(() async {
    await scheduler.cancelEverything();
    await db.close();
  });

  testWidgets('schedule → reschedule → cancel leaves zero pending notifications',
      (tester) async {
    // Far enough out that every reminder is still in the future.
    final soon = shopNow().add(const Duration(days: 4));
    final draft = JobDraft(
      customerName: 'Siti',
      phone: '+60123608968',
      service: ServiceType.pantsJeansShortening,
      dropOff: AppointmentDraft(
        at: shopDateTime(soon.year, soon.month, soon.day, 12, 0),
      ),
    );

    // 1. Schedule.
    final jobId = await repository.save(draft);
    final afterSchedule = await notifications.pending();
    expect(afterSchedule, isNotEmpty);
    await _expectOsMatchesLedger(db, notifications);

    // 2. Reschedule to a different day and time.
    final later = shopNow().add(const Duration(days: 9));
    await repository.save(
      draft
        ..jobId = jobId
        ..dropOff = AppointmentDraft(
          at: shopDateTime(later.year, later.month, later.day, 16, 0),
        ),
    );
    await _expectOsMatchesLedger(db, notifications);

    // 3. Cancel.
    await repository.deleteJob(jobId);

    expect(await db.allPending(), isEmpty);
    expect(await notifications.pending(), isEmpty);
  });

  testWidgets('cancelling the appointment alone also clears its reminders',
      (tester) async {
    final soon = shopNow().add(const Duration(days: 4));
    final jobId = await repository.save(
      JobDraft(
        customerName: 'Ah Meng',
        phone: '+60123608968',
        service: ServiceType.basicAlterations,
        dropOff: AppointmentDraft(
          at: shopDateTime(soon.year, soon.month, soon.day, 12, 0),
        ),
      ),
    );
    expect(await notifications.pending(), isNotEmpty);

    await repository.setAppointmentStatus(
      jobId,
      AppointmentType.dropOff,
      AppointmentStatus.cancelled,
    );

    expect(await db.allPending(), isEmpty);
    expect(await notifications.pending(), isEmpty);
  });
}

/// The invariant: the OS holds exactly the ids the ledger says are registered.
Future<void> _expectOsMatchesLedger(
  AppDatabase db,
  NotificationService notifications,
) async {
  final ledger = await db.allPending();
  final expected =
      ledger.where((row) => row.registered).map((row) => row.id).toSet();
  final actual = (await notifications.pending())
      .map((PendingNotificationRequest request) => request.id)
      .toSet();
  expect(actual, expected);
}
