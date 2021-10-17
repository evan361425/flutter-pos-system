import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/providers/currency_provider.dart';
import 'package:possystem/providers/language_provider.dart';
import 'package:possystem/ui/analysis/analysis_screen.dart';
import 'package:provider/provider.dart';

import '../../mocks/mock_cache.dart';
import '../../mocks/mock_database.dart';

void main() {
  Widget buildAnalysisScreen({themeMode = ThemeMode.light}) {
    final language = LanguageProvider();
    final currency = CurrencyProvider();
    final defaultLanguage = Locale('zh', 'TW');
    // provider setting
    when(cache.set(any, any)).thenAnswer((_) => Future.value(true));
    language.setLocale(defaultLanguage);
    currency.setCurrency(CurrencyTypes.TWD);

    return MaterialApp(
      themeMode: themeMode,
      theme: ThemeData(),
      darkTheme: ThemeData.dark(),
      locale: defaultLanguage,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: language),
          ChangeNotifierProvider.value(value: Seller()),
        ],
        builder: (_, __) => AnalysisScreen(),
      ),
    );
  }

  void mockGetOrderBetween(List<Map<String, Object?>> data) {
    when(database.query(
      Seller.ORDER_TABLE,
      columns: anyNamed('columns'),
      where: anyNamed('where'),
      whereArgs: anyNamed('whereArgs'),
      join: argThat(isNotNull, named: 'join'),
      orderBy: anyNamed('orderBy'),
      limit: anyNamed('limit'),
      offset: anyNamed('offset'),
    )).thenAnswer((_) => Future.value(data));
  }

  void mockGetCountBetween(List<Map<String, Object>> data) {
    when(database.query(
      Seller.ORDER_TABLE,
      columns: anyNamed('columns'),
      where: anyNamed('where'),
      whereArgs: anyNamed('whereArgs'),
      groupBy: argThat(isNotNull, named: 'groupBy'),
    )).thenAnswer((_) => Future.value(data));
  }

  void mockGetMetricBetween(List<Map<String, Object>> data) {
    when(database.query(
      Seller.ORDER_TABLE,
      columns: argThat(
        predicate(
            (data) => data is List && data[1] == 'SUM(totalPrice) totalPrice'),
        named: 'columns',
      ),
      where: anyNamed('where'),
      whereArgs: anyNamed('whereArgs'),
    )).thenAnswer((_) => Future.value(data));
  }

  testWidgets('select date and show order list in portrait', (tester) async {
    final now = DateTime.now();
    mockGetOrderBetween([
      {'id': 1},
      {'id': 2},
    ]);
    mockGetMetricBetween([]);
    mockGetCountBetween([
      {
        'createdAt': now.millisecondsSinceEpoch ~/ 1000,
        'count': 100, // show 99+
      },
      {
        // yesterday
        'createdAt': now.millisecondsSinceEpoch ~/ 1000 - 86400,
        'count': 50,
      },
    ]);

    // setup protrait env
    tester.binding.window.physicalSizeTestValue = Size(1000, 2000);

    // resets the screen to its orinal size after the test end
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

    await tester.pumpWidget(buildAnalysisScreen());
    await tester.pumpAndSettle();

    expect(find.text('99+'), findsOneWidget);

    // change format
    await tester.tap(find.text('month'));
    await tester.pumpAndSettle();

    // select date
    await tester.tap(find.text(now.day.toString()));
    await tester.pumpAndSettle();

    // find by OrderTile key
    expect(find.byKey(Key('analysis.order_list.1')), findsOneWidget);
    expect(find.byKey(Key('analysis.order_list.2')), findsOneWidget);
  });

  testWidgets('load count when page changed in landscape', (tester) async {
    final now = DateTime.now();
    mockGetCountBetween([
      {
        'createdAt': now.millisecondsSinceEpoch ~/ 1000,
        'count': 50,
      },
      {
        // last month
        'createdAt': now.millisecondsSinceEpoch ~/ 1000 - 86400 * (now.day + 7),
        'count': 60,
      },
    ]);

    // setup landscape env
    tester.binding.window.physicalSizeTestValue = Size(2000, 1000);

    // resets the screen to its orinal size after the test end
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

    await tester.pumpWidget(buildAnalysisScreen(themeMode: ThemeMode.dark));
    await tester.pumpAndSettle();

    expect(find.text('50'), findsOneWidget);
    expect(find.text('60'), findsNothing);

    // go to prev page(month)
    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();

    expect(find.text('50'), findsNothing);
    expect(find.text('60'), findsOneWidget);
  });

  setUpAll(() {
    initializeCache();
    initializeDatabase();
  });
}
