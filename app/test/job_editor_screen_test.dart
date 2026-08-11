import 'dart:io';

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
import 'package:anacoo_tailor/ui/job/job_editor_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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
    photoRoot = Directory.systemTemp.createTempSync('job-editor-photos');
    photos = ClothPhotoStore(root: photoRoot);
  });

  tearDown(() async {
    await db.close();
    photoRoot.deleteSync(recursive: true);
  });

  Future<int> seedJob() {
    final repository = JobRepository(
      db: db,
      scheduler: NotificationScheduler(db: db, sink: _SilentNotifications()),
      photos: photos,
    );
    return repository.save(
      JobDraft(
        customerName: 'Junyx Tan',
        phone: '0123608968',
        service: ServiceType.curtainsBedsheets,
        dropOff: AppointmentDraft(at: shopDateTime(2026, 8, 13, 12, 0)),
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

  /// Pumps [home] on top of a placeholder route, so a screen that closes itself
  /// has somewhere to go — which is the whole point of these tests.
  Future<void> pumpPushed(WidgetTester tester, Widget home) async {
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
          locale: const Locale('en'),
          supportedLocales: AppStrings.supportedLocales,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => home),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  /// The delete button sits at the very bottom of a lazy list, so it does not
  /// exist until it is scrolled into range.
  Future<void> scrollToBottom(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();
    }
  }

  /// Deleting a job removes its photo directory from disk before the screen
  /// closes. Real file I/O never completes against the test's fake clock, so
  /// pumping alone would wait forever — [WidgetTester.runAsync] is what lets it
  /// finish.
  Future<void> settleDelete(WidgetTester tester) async {
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();
  }

  Finder appBarIcon(IconData icon) => find.descendant(
        of: find.byType(AppBar),
        matching: find.byIcon(icon),
      );

  testWidgets('job detail has no overflow menu', (tester) async {
    final jobId = await seedJob();
    await pumpPushed(tester, JobDetailScreen(jobId: jobId));

    expect(find.byType(PopupMenuButton<void>), findsNothing);
    expect(find.byIcon(Icons.more_vert), findsNothing);
    // Editing is still one tap from the job.
    expect(appBarIcon(Icons.edit_outlined), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('the editor offers Delete for a job that exists',
      (tester) async {
    final jobId = await seedJob();
    await pumpPushed(tester, JobEditorScreen(jobId: jobId));
    await scrollToBottom(tester);

    expect(find.widgetWithText(TextButton, 'Delete'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('the editor offers no Delete for a job not saved yet',
      (tester) async {
    await pumpPushed(tester, const JobEditorScreen());
    await scrollToBottom(tester);

    expect(find.widgetWithText(TextButton, 'Delete'), findsNothing);
    // Save is still there, so this is the bottom of the form, not a dud scroll.
    expect(find.widgetWithText(FilledButton, 'Save'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('Delete asks first, and a refusal leaves the job alone',
      (tester) async {
    final jobId = await seedJob();
    await pumpPushed(tester, JobEditorScreen(jobId: jobId));
    await scrollToBottom(tester);

    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Delete job?'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(await db.watchJobBundle(jobId).first, isNotNull);
    // Still on the editor, so a mis-tap costs nothing.
    expect(find.byType(JobEditorScreen), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('confirming Delete removes the job and closes the editor',
      (tester) async {
    final jobId = await seedJob();
    await pumpPushed(tester, JobEditorScreen(jobId: jobId));
    await scrollToBottom(tester);

    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await settleDelete(tester);

    expect(await db.watchJobBundle(jobId).first, isNull);
    expect(find.byType(JobEditorScreen), findsNothing);
    await unmount(tester);
  });

  testWidgets('job detail closes itself once its job is gone', (tester) async {
    final jobId = await seedJob();
    await pumpPushed(tester, JobDetailScreen(jobId: jobId));
    expect(find.byType(JobDetailScreen), findsOneWidget);

    await tester.tap(appBarIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    await scrollToBottom(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await settleDelete(tester);

    // Both the editor and the job it was editing are gone, leaving the screen
    // the tailor came from rather than an empty job page.
    expect(find.byType(JobEditorScreen), findsNothing);
    expect(find.byType(JobDetailScreen), findsNothing);
    expect(find.text('open'), findsOneWidget);
    await unmount(tester);
  });
}
