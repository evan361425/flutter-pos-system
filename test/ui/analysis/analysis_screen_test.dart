import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/settings/language_setting.dart';
import 'package:possystem/settings/settings_provider.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/analysis/analysis_screen.dart';
import 'package:provider/provider.dart';

import '../../mocks/mock_cache.dart';
import '../../mocks/mock_database.dart';
import '../../test_helpers/translator.dart';

void main() {
  Widget buildAnalysisScreen({themeMode = ThemeMode.light}) {
    // setup currency and cashier relation
    when(cache.get(any)).thenReturn(null);
    // disable tutorial
    when(cache.get(
      argThat(predicate<String>((key) => key.startsWith('tutorial.'))),
    )).thenReturn(true);
    final settings = SettingsProvider([
      LanguageSetting(),
      CurrencySetting(),
    ]);

    return MaterialApp(
      themeMode: themeMode,
      theme: ThemeData(),
      darkTheme: ThemeData.dark(),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: settings),
          ChangeNotifierProvider.value(value: Seller()),
        ],
        builder: (_, __) => Scaffold(body: AnalysisScreen()),
      ),
    );
  }

  Future<List<Map<String, Object?>>> mockGetOrderBetween() {
    return database.query(
      Seller.orderTable,
      columns: argThat(isNull, named: 'columns'),
      where: argThat(equals('createdAt BETWEEN ? AND ?'), named: 'where'),
      whereArgs: anyNamed('whereArgs'),
      join: argThat(isNull, named: 'join'),
      orderBy: anyNamed('orderBy'),
      limit: anyNamed('limit'),
      offset: anyNamed('offset'),
    );
  }

  Future<List<Map<String, Object?>>> mockGetCountBetween() {
    return database.query(
      Seller.orderTable,
      columns: argThat(
        predicate((data) =>
            data is List && data.length == 1 && data[0] == 'createdAt'),
        named: 'columns',
      ),
      where: anyNamed('where'),
      whereArgs: anyNamed('whereArgs'),
    );
  }

  Future<List<Map<String, Object?>>> mockGetMetricBetween() {
    return database.query(
      Seller.orderTable,
      columns: argThat(
        predicate((data) =>
            data is List &&
            data.length == 2 &&
            data[1] == 'SUM(totalPrice) totalPrice'),
        named: 'columns',
      ),
      where: anyNamed('where'),
      whereArgs: anyNamed('whereArgs'),
    );
  }

  group('Analysis Screen', () {
    testWidgets('select date and show order list in portrait', (tester) async {
      final now = DateTime.now();
      final nowS = now.millisecondsSinceEpoch ~/ 1000;
      when(mockGetOrderBetween()).thenAnswer((_) => Future.value([
            {'id': 1},
            {'id': 2},
          ]));
      when(mockGetMetricBetween()).thenAnswer((_) => Future.value([]));
      when(mockGetCountBetween()).thenAnswer((_) => Future.value([
            ...List.filled(100, {'createdAt': nowS}),
            ...List.filled(50, {'createdAt': nowS - 86400}),
          ]));

      // setup portrait env
      tester.binding.window.physicalSizeTestValue = const Size(1000, 2000);

      // resets the screen to its original size after the test end
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpWidget(buildAnalysisScreen());
      await tester.pumpAndSettle();

      expect(find.text('99+'), findsOneWidget);

      // change format
      await tester.tap(find.text(S.analysisCalendarMonth));
      await tester.pumpAndSettle();

      // select date
      await tester.tap(find.text(now.day.toString()));
      await tester.pumpAndSettle();

      // find by OrderTile key
      expect(find.byKey(const Key('analysis.order_list.1')), findsOneWidget);
      expect(find.byKey(const Key('analysis.order_list.2')), findsOneWidget);
    });

    testWidgets('load count when page changed in landscape', (tester) async {
      final now = DateTime.now();
      final nowS = now.millisecondsSinceEpoch ~/ 1000;
      when(mockGetCountBetween()).thenAnswer((_) => Future.value([
            ...List.filled(50, {'createdAt': nowS}),
            // last month
            ...List.filled(60, {'createdAt': nowS - 86400 * (now.day + 7)}),
          ]));
      when(mockGetMetricBetween()).thenAnswer((_) => Future.value([]));
      when(mockGetOrderBetween()).thenAnswer((_) => Future.value([]));

      // setup landscape env
      tester.binding.window.physicalSizeTestValue = const Size(2000, 1000);

      // resets the screen to its original size after the test end
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpWidget(buildAnalysisScreen(themeMode: ThemeMode.dark));
      await tester.pumpAndSettle();

      expect(find.text('50'), findsOneWidget);
      expect(find.text('60'), findsNothing);
      // verify it has load orders after initialized
      verify(mockGetMetricBetween());
      verify(mockGetOrderBetween());
      verify(mockGetCountBetween());

      // go to prev page(month)
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      expect(find.text('50'),
          now.day < now.weekday ? findsOneWidget : findsNothing);
      expect(find.text('60'), findsOneWidget);
    });

    setUpAll(() {
      initializeCache();
      initializeDatabase();
      initializeTranslator();
    });
  });
}
