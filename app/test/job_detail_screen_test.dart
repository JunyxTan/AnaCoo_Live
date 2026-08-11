import 'dart:io';

import 'package:anacoo_tailor/core/formatting.dart';
import 'package:anacoo_tailor/core/theme.dart';
import 'package:anacoo_tailor/data/database.dart';
import 'package:anacoo_tailor/data/enums.dart';
import 'package:anacoo_tailor/data/job_repository.dart';
import 'package:anacoo_tailor/domain/notification_plan.dart';
import 'package:anacoo_tailor/domain/shop_time.dart';
import 'package:anacoo_tailor/l10n/app_strings.dart';
import 'package:anacoo_tailor/providers/providers.dart';
import 'package:anacoo_tailor/services/cloth_photo_store.dart';
import 'package:anacoo_tailor/services/notification_scheduler.dart';
import 'package:anacoo_tailor/services/notification_service.dart';
import 'package:anacoo_tailor/ui/job/job_detail_screen.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Keeps the scheduler happy without touching a platform channel.
class _SilentNotifications extends NotificationService {
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
  late Directory photoRoot;
  late ClothPhotoStore photos;

  setUp(() async {
    db = AppDatabase.memory();
    await db.loadSettings();
    photoRoot = Directory.systemTemp.createTempSync('job-detail-photos');
    photos = ClothPhotoStore(root: photoRoot);
  });

  tearDown(() async {
    await db.close();
    photoRoot.deleteSync(recursive: true);
  });

  Future<int> seedJob({JobStatus status = JobStatus.booked}) {
    final repository = JobRepository(
      db: db,
      scheduler: NotificationScheduler(db: db, sink: _SilentNotifications()),
      photos: photos,
    );
    return repository.save(
      JobDraft(
        customerName: 'Junyx Tan',
        phone: '0123608968',
        service: ServiceType.pantsJeansShortening,
        itemDescription: 'Blue jeans',
        quotedPrice: 45,
        depositPaid: 20,
        status: status,
        dropOff: AppointmentDraft(at: shopDateTime(2026, 8, 13, 12, 0)),
        collection: AppointmentDraft(at: shopDateTime(2026, 8, 16, 15, 30)),
      ),
    );
  }

  /// Unmounts the tree and drains drift's cleanup timers.
  ///
  /// Dropping the last listener on a drift stream schedules a zero-duration
  /// timer, and closing one stream closes the next, so the binding's
  /// "no pending timers" check only passes after a few empty frames.
  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    for (var i = 0; i < 5; i++) {
      await tester.pump(Duration.zero);
    }
  }

  Future<void> pumpDetail(
    WidgetTester tester,
    int jobId, {
    String language = 'en',
  }) async {
    await db.saveSettings(AppSettingsCompanion(languageCode: Value(language)));
    // A phone-shaped viewport: this page is only ever read on one.
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          notificationServiceProvider.overrideWithValue(_SilentNotifications()),
          clothPhotoStoreProvider.overrideWithValue(photos),
        ],
        child: MaterialApp(
          theme: AnacooTheme.light(),
          locale: Locale(language),
          supportedLocales: AppStrings.supportedLocales,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: JobDetailScreen(jobId: jobId),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the customer, the whole pipeline and the figures',
      (tester) async {
    final jobId = await seedJob();
    await pumpDetail(tester, jobId);

    // Name in the app bar and on the customer card.
    expect(find.text('Junyx Tan'), findsNWidgets(2));
    expect(find.text('+60123608968'), findsOneWidget);

    // Every pipeline step keeps its label, not just the current one.
    for (final label in ['Booked', 'Sewing', 'Ready', 'Done']) {
      expect(find.text(label), findsWidgets, reason: 'missing step $label');
    }
    expect(find.text('Next · Sewing'), findsOneWidget);

    // The steps carry their dates: booked today, sewing when the garment
    // arrives, done when it is collected.
    const formats = Formats('en');
    expect(find.text(formats.dayMonth(shopNow())), findsOneWidget);
    expect(find.text(formats.dayMonth(shopDateTime(2026, 8, 13))), findsOneWidget);
    expect(find.text(formats.dayMonth(shopDateTime(2026, 8, 16))), findsOneWidget);

    expect(find.text('Pants / jeans shortening'), findsOneWidget);
    expect(find.text('Blue jeans'), findsOneWidget);
    expect(find.text('RM 45'), findsOneWidget);
    expect(find.text('RM 20'), findsOneWidget);
    // Price less deposit, spelled out so nobody has to do it at the counter.
    expect(find.text('RM 25.00'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('both appointments show their day, time and status',
      (tester) async {
    final jobId = await seedJob();
    await pumpDetail(tester, jobId);

    await tester.drag(find.byType(ListView), const Offset(0, -420));
    await tester.pumpAndSettle();

    expect(find.text('13'), findsOneWidget);
    expect(find.text('16'), findsOneWidget);
    // `intl` separates the meridiem with a narrow no-break space, so match on
    // the parts rather than the whole line.
    expect(find.textContaining('12:00'), findsOneWidget);
    expect(find.textContaining('3:30'), findsOneWidget);
    expect(find.textContaining('15 min'), findsNWidgets(2));
    expect(find.text('Pending'), findsNWidgets(2));
    await unmount(tester);
  });

  testWidgets('the reply buttons stay reachable without scrolling',
      (tester) async {
    final jobId = await seedJob();
    await pumpDetail(tester, jobId);

    for (final label in ['Confirm', 'Ready', 'Reschedule']) {
      expect(find.text(label), findsWidgets);
    }

    // Still there after scrolling to the bottom of a long job.
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('Reschedule'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('a pipeline step can be tapped to set the status',
      (tester) async {
    final jobId = await seedJob();
    await pumpDetail(tester, jobId);

    await tester.tap(find.text('Ready').first);
    await tester.pumpAndSettle();

    final job = await db.getJob(jobId);
    expect(job.status, JobStatus.ready);
    await unmount(tester);
  });

  testWidgets('the status pill opens a picker that sets the appointment status',
      (tester) async {
    final jobId = await seedJob();
    await pumpDetail(tester, jobId);

    await tester.drag(find.byType(ListView), const Offset(0, -420));
    await tester.pumpAndSettle();

    // Two appointments, so two pills — the first belongs to the drop-off.
    expect(find.text('Pending'), findsNWidgets(2));
    await tester.tap(find.text('Pending').first);
    await tester.pumpAndSettle();

    // The sheet lists every status; picking one closes it.
    expect(find.text('No-show'), findsOneWidget);
    await tester.tap(find.text('OK').last);
    await tester.pumpAndSettle();

    final dropOff = await db.appointmentOf(jobId, AppointmentType.dropOff);
    expect(dropOff!.status, AppointmentStatus.confirmed);
    final collection = await db.appointmentOf(jobId, AppointmentType.collection);
    expect(collection!.status, AppointmentStatus.pending);
    await unmount(tester);
  });

  testWidgets('a job sitting in ready is dated from when it got there',
      (tester) async {
    final jobId = await seedJob(status: JobStatus.ready);
    await pumpDetail(tester, jobId);

    const formats = Formats('en');
    final job = await db.getJob(jobId);
    expect(job.readyAt, isNotNull);
    // Booked and ready both land on today, so the date shows up twice.
    expect(find.text(formats.dayMonth(shopNow())), findsNWidgets(2));
    await unmount(tester);
  });

  testWidgets('a cancelled job says so instead of drawing a pipeline',
      (tester) async {
    final jobId = await seedJob(status: JobStatus.cancelled);
    await pumpDetail(tester, jobId);

    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Booked'), findsNothing);
    expect(find.text('Next · Sewing'), findsNothing);
    await unmount(tester);
  });

  testWidgets('renders in Vietnamese, dates included', (tester) async {
    final jobId = await seedJob();
    await pumpDetail(tester, jobId, language: 'vi');

    for (final label in ['Đã đặt', 'Đang may', 'Sẵn sàng', 'Hoàn tất']) {
      expect(find.text(label), findsWidgets, reason: 'missing step $label');
    }
    expect(find.text('Tiếp · Đang may'), findsOneWidget);
    expect(find.text('Cắt lai quần / quần jean'), findsOneWidget);

    // `intl` has Vietnamese date symbols, so the steps are dated in Vietnamese
    // rather than falling back to English month names.
    const formats = Formats('vi');
    expect(formats.dayMonth(shopDateTime(2026, 8, 13)),
        isNot(const Formats('en').dayMonth(shopDateTime(2026, 8, 13))));
    expect(find.text(formats.dayMonth(shopDateTime(2026, 8, 13))), findsOneWidget);
    await unmount(tester);
  });
}
