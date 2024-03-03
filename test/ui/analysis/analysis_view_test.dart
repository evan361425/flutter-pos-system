import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/analysis/analysis.dart';
import 'package:possystem/models/analysis/chart.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/settings/language_setting.dart';
import 'package:possystem/settings/settings_provider.dart';
import 'package:possystem/ui/analysis/analysis_view.dart';
import 'package:provider/provider.dart';

import '../../mocks/mock_cache.dart';
import '../../mocks/mock_database.dart';
import '../../mocks/mock_storage.dart';
import '../../test_helpers/translator.dart';

void main() {
  group('Analysis View', () {
    Widget buildApp({themeMode = ThemeMode.light}) {
      when(cache.get(any)).thenReturn(null);
      // disable tutorial
      when(cache.get(
        argThat(predicate<String>((key) => key.startsWith('tutorial.'))),
      )).thenReturn(true);
      final settings = SettingsProvider([
        LanguageSetting(),
        CurrencySetting(),
      ]);

      return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: settings),
          ChangeNotifierProvider.value(value: Seller.instance),
        ],
        builder: (_, __) => MaterialApp.router(
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (_, __) {
                  return const Scaffold(body: AnalysisView());
                },
                routes: Routes.routes,
              ),
            ],
          ),
        ),
      );
    }

    void mockGetMetrics() {
      when(database.query(
        Seller.orderTable,
        columns: argThat(contains('COUNT(*) count'), named: 'columns'),
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) => Future.value([{}]));
    }

    void mockGetChart() {
      when(database.query(
        any,
        columns: argThat(contains('SUM(t.price) price'), named: 'columns'),
        orderBy: anyNamed('orderBy'),
        escapeTable: anyNamed('escapeTable'),
        groupBy: anyNamed('groupBy'),
      )).thenAnswer((_) => Future.value([{}]));
    }

    void mockGetOrder() {
      when(database.query(
        Seller.orderTable,
        columns: anyNamed('columns'),
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
        orderBy: anyNamed('orderBy'),
        limit: argThat(equals(10), named: 'limit'),
        offset: anyNamed('offset'),
        join: anyNamed('join'),
        groupBy: anyNamed('groupBy'),
      )).thenAnswer((_) => Future.value([]));
      when(database.query(
        any,
        columns: anyNamed('columns'),
        groupBy: argThat(equals('t.day'), named: 'groupBy'),
        orderBy: anyNamed('orderBy'),
        whereArgs: anyNamed('whereArgs'),
        escapeTable: false,
      )).thenAnswer((_) => Future.value([]));
    }

    testWidgets('navigate to history', (tester) async {
      mockGetMetrics();
      mockGetOrder();
      Analysis();

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('anal.history')));
      await tester.pumpAndSettle();
    });

    testWidgets('add chart', (tester) async {
      Analysis();
      mockGetMetrics();
      mockGetChart();
      when(storage.add(any, any, any)).thenAnswer((_) => Future.value());

      await tester.pumpWidget(buildApp());
      await tester.tap(find.byKey(const Key('anal.add_chart')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('chart.title')), 'test');
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('modal.save')));
      await tester.pumpAndSettle();

      final chart = Analysis.instance.items.first;
      verify(storage.add(
        any,
        argThat(equals(chart.id)),
        argThat(predicate((data) => data is Map && data['name'] == 'test')),
      ));

      expect(find.text('test'), findsOneWidget);
      expect(find.byKey(Key('chart.${chart.id}.reset')), findsOneWidget);
      expect(chart.name, equals('test'));
      // verify default values
      expect(chart.type.name, equals('cartesian'));
      expect(chart.ignoreEmpty, equals(true));
      expect(chart.withToday, equals(false));
      expect(chart.range.duration, equals(const Duration(days: 7)));
      expect(chart is CartesianChart, isTrue);
      expect(chart.target, OrderMetricTarget.order);
      expect(chart.metrics, equals(const [OrderMetricType.price]));
      expect(chart.targetItems, isEmpty);
    });

    setUpAll(() {
      initializeCache();
      initializeDatabase();
      initializeStorage();
      initializeTranslator();
    });
  });
}
