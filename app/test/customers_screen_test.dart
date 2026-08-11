import 'package:anacoo_tailor/core/theme.dart';
import 'package:anacoo_tailor/data/database.dart';
import 'package:anacoo_tailor/domain/shop_time.dart';
import 'package:anacoo_tailor/l10n/app_strings.dart';
import 'package:anacoo_tailor/providers/providers.dart';
import 'package:anacoo_tailor/ui/customers/customers_screen.dart';
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

  Future<int> addCustomer(String name) => db.upsertCustomer(
        CustomersCompanion.insert(
          name: name,
          phone: const Value('0123608968'),
          createdAt: DateTime.now().toUtc(),
        ),
      );

  /// Unmounts the tree and drains drift's cleanup timers.
  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    for (var i = 0; i < 5; i++) {
      await tester.pump(Duration.zero);
    }
  }

  Future<void> pumpCustomers(WidgetTester tester) async {
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
          home: const CustomersScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// The swipe itself: right to left, far enough to pass the dismiss threshold.
  Future<void> swipeLeft(WidgetTester tester, String name) async {
    await tester.drag(find.text(name), const Offset(-500, 0));
    await tester.pumpAndSettle();
  }

  testWidgets('swiping a name left archives it', (tester) async {
    final ana = await addCustomer('Ana');
    await addCustomer('Bob');
    await pumpCustomers(tester);

    expect(find.text('Ana'), findsOneWidget);
    await swipeLeft(tester, 'Ana');

    // Gone from the list, and archived rather than deleted.
    expect(find.text('Ana'), findsNothing);
    expect(find.text('Bob'), findsOneWidget);
    expect((await db.getCustomer(ana)).archivedAt, isNotNull);
    await unmount(tester);
  });

  testWidgets('the swipe offers Undo, which puts the name back',
      (tester) async {
    final ana = await addCustomer('Ana');
    await pumpCustomers(tester);

    await swipeLeft(tester, 'Ana');
    expect(find.text('Undo'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect((await db.getCustomer(ana)).archivedAt, isNull);
    expect(find.text('Ana'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('the archive is reachable, and a swipe there restores',
      (tester) async {
    final ana = await addCustomer('Ana');
    await pumpCustomers(tester);
    await swipeLeft(tester, 'Ana');

    // The snackbar would sit over the list and eat the swipe.
    ScaffoldMessenger.of(tester.element(find.byType(CustomersScreen)))
        .removeCurrentSnackBar();
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Archived'));
    await tester.pumpAndSettle();
    expect(find.text('Ana'), findsOneWidget);

    await swipeLeft(tester, 'Ana');

    expect((await db.getCustomer(ana)).archivedAt, isNull);
    // Back in the directory, so the archive is empty again.
    expect(find.text('Nothing archived'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('swiping the other way does nothing', (tester) async {
    final ana = await addCustomer('Ana');
    await pumpCustomers(tester);

    await tester.drag(find.text('Ana'), const Offset(500, 0));
    await tester.pumpAndSettle();

    expect(find.text('Ana'), findsOneWidget);
    expect((await db.getCustomer(ana)).archivedAt, isNull);
    await unmount(tester);
  });
}
