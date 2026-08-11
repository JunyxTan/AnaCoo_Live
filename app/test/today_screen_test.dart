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
import 'package:anacoo_tailor/ui/today/today_screen.dart';
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
  late JobRepository repository;

  setUp(() async {
    db = AppDatabase.memory();
    await db.loadSettings();
    photoRoot = Directory.systemTemp.createTempSync('today-photos');
    photos = ClothPhotoStore(root: photoRoot);
    repository = JobRepository(
      db: db,
      scheduler: NotificationScheduler(db: db, sink: _SilentNotifications()),
      photos: photos,
    );
  });

  tearDown(() async {
    await db.close();
    photoRoot.deleteSync(recursive: true);
  });

  /// Seeds [count] upcoming drop-offs, far enough ahead to stay off the history
  /// side of the list.
  Future<void> seedJobs(int count) async {
    for (var i = 0; i < count; i++) {
      await repository.save(
        JobDraft(
          customerName: 'Customer $i',
          phone: '01236089$i$i',
          service: ServiceType.curtainsBedsheets,
          dropOff: AppointmentDraft(
            at: shopDateTime(2026, 8, 20 + i, 10, 0),
          ),
        ),
      );
    }
  }

  /// Unmounts the tree and drains drift's cleanup timers.
  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    for (var i = 0; i < 5; i++) {
      await tester.pump(Duration.zero);
    }
  }

  /// The screen as the shell hosts it: a tab in a scaffold that owns the
  /// navigation bar, on a phone-shaped viewport.
  Future<void> pumpToday(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 780));
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
          supportedLocales: AppStrings.supportedLocales,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            body: TodayScreen(onPasteAppointment: () {}, onNewJob: () {}),
            bottomNavigationBar: NavigationBar(
              selectedIndex: 0,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.event_note_outlined),
                  label: 'Appointments',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// The button carrying [label], whichever emphasis it is drawn with.
  Finder buttonFinder(String label) => find.ancestor(
        of: find.text(label),
        matching: find.byWidgetPredicate((widget) => widget is ButtonStyleButton),
      );

  testWidgets('all four actions sit in a bar below the list', (tester) async {
    await seedJobs(2);
    await pumpToday(tester);

    final listBottom = tester.getRect(find.byType(ListView)).bottom;
    for (final label in ['Paste', 'New', 'Filter', 'Sort']) {
      final button = tester.getRect(buttonFinder(label));
      expect(
        button.top,
        greaterThanOrEqualTo(listBottom),
        reason: '$label should be below the list, not in it',
      );
    }

    // Clear of the navigation bar below it, which owns the screen's bottom edge.
    final navTop = tester.getRect(find.byType(NavigationBar)).top;
    expect(tester.getRect(buttonFinder('Sort')).bottom, lessThan(navTop));
    await unmount(tester);
  });

  testWidgets('the actions stay put while the list scrolls', (tester) async {
    await seedJobs(12);
    await pumpToday(tester);

    final before = tester.getRect(buttonFinder('Paste'));
    expect(find.text('Customer 0'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();

    // The list moved under them; the buttons did not move with it.
    expect(find.text('Customer 0'), findsNothing);
    expect(tester.getRect(buttonFinder('Paste')), before);
    await unmount(tester);
  });

  testWidgets('an empty day still offers every action', (tester) async {
    await pumpToday(tester);

    expect(find.text('No appointments'), findsOneWidget);
    for (final label in ['Paste', 'New', 'Filter', 'Sort']) {
      expect(buttonFinder(label), findsOneWidget, reason: label);
    }
    await unmount(tester);
  });
}
