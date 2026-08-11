import 'package:anacoo_tailor/core/theme.dart';
import 'package:anacoo_tailor/data/database.dart';
import 'package:anacoo_tailor/domain/notification_plan.dart';
import 'package:anacoo_tailor/domain/shop_time.dart';
import 'package:anacoo_tailor/l10n/app_strings.dart';
import 'package:anacoo_tailor/providers/providers.dart';
import 'package:anacoo_tailor/services/notification_service.dart';
import 'package:anacoo_tailor/ui/settings/settings_screen.dart';
import 'package:anacoo_tailor/ui/settings/templates_screen.dart';
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

  setUp(() async {
    db = AppDatabase.memory();
    await db.loadSettings();
    await db.saveSettings(const AppSettingsCompanion(languageCode: Value('en')));
  });

  tearDown(() async => db.close());

  Future<void> pumpSettings(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          notificationServiceProvider.overrideWithValue(_SilentNotifications()),
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
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Confirm · Ready · Reschedule'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  /// Unmounts the tree and drains drift's cleanup timers.
  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    for (var i = 0; i < 5; i++) {
      await tester.pump(Duration.zero);
    }
  }

  testWidgets('the templates section says Templates once, not twice',
      (tester) async {
    await pumpSettings(tester);

    // The heading names the section; the row below it names what is inside,
    // rather than saying Templates a second time.
    expect(find.text('Templates'), findsOneWidget);
    expect(find.text('Confirm · Ready · Reschedule'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('the row still opens the template editor', (tester) async {
    await pumpSettings(tester);

    await tester.tap(find.text('Confirm · Ready · Reschedule'));
    await tester.pumpAndSettle();

    expect(find.byType(TemplatesScreen), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('slot, turnaround and language are picked from a dropdown',
      (tester) async {
    await pumpSettings(tester);

    // Closed controls show the current value; the old bottom-sheet list of
    // every option is gone, and so is the five-row language stack.
    expect(find.text('30 min'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Bahasa Melayu'), findsNothing);
    expect(find.byType(DropdownButton<String>), findsOneWidget);

    await tester.tap(find.text('30 min'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('45 min').last);
    await tester.pumpAndSettle();
    expect((await db.loadSettings()).slotMinutes, 45);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bahasa Melayu').last);
    await tester.pumpAndSettle();
    expect((await db.loadSettings()).languageCode, 'ms');
    await unmount(tester);
  });
}
