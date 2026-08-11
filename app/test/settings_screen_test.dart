import 'package:anacoo_tailor/core/theme.dart';
import 'package:anacoo_tailor/data/database.dart';
import 'package:anacoo_tailor/domain/shop_time.dart';
import 'package:anacoo_tailor/l10n/app_strings.dart';
import 'package:anacoo_tailor/providers/providers.dart';
import 'package:anacoo_tailor/ui/settings/settings_screen.dart';
import 'package:anacoo_tailor/ui/settings/templates_screen.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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
        overrides: [databaseProvider.overrideWithValue(db)],
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
}
