import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/analysis/analysis.dart';
import 'package:possystem/models/analysis/chart.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/settings/language_setting.dart';
import 'package:possystem/settings/settings_provider.dart';
import 'package:possystem/ui/analysis/analysis_view.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

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

    void mockGetChart() {
      when(database.query(
        any,
        columns: argThat(contains('SUM(price) price'), named: 'columns'),
        orderBy: anyNamed('orderBy'),
        escapeTable: anyNamed('escapeTable'),
        groupBy: anyNamed('groupBy'),
        limit: anyNamed('limit'),
        offset: anyNamed('offset'),
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
        groupBy: argThat(equals('day'), named: 'groupBy'),
        orderBy: anyNamed('orderBy'),
        whereArgs: anyNamed('whereArgs'),
        escapeTable: false,
      )).thenAnswer((_) => Future.value([]));
    }

    testWidgets('navigate to history', (tester) async {
      mockGetChart();
      mockGetOrder();
      Analysis();

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('anal.history')));
      await tester.pumpAndSettle();
    });

    testWidgets('interact with chart', (tester) async {
      Analysis().replaceItems({
        'origin': Chart(
          id: 'origin',
          name: 'origin',
          index: 1,
          type: AnalysisChartType.cartesian,
          ignoreEmpty: false,
          target: OrderMetricTarget.order,
          metrics: const [OrderMetricType.price],
          targetItems: [],
        ),
      });
      mockGetChart();
      when(storage.add(any, any, any)).thenAnswer((_) => Future.value());

      await tester.pumpWidget(buildApp());

      await tester.tap(find.byKey(const Key('anal.add_chart')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('chart.title')), 'test');
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('modal.save')));
      await tester.pumpAndSettle();

      final chart = Analysis.instance.items.last;
      verify(storage.add(
        any,
        argThat(equals(chart.id)),
        argThat(predicate((data) => data is Map && data['name'] == 'test')),
      ));

      expect(find.text('test'), findsOneWidget);
      expect(find.byKey(Key('chart.${chart.id}.more')), findsOneWidget);
      expect(chart.name, equals('test'));
      // verify default values
      expect(chart.type.name, equals('cartesian'));
      expect(chart.ignoreEmpty, equals(false));
      expect(chart.target, OrderMetricTarget.order);
      expect(chart.metrics, equals(const [OrderMetricType.price]));
      expect(chart.targetItems, isEmpty);
      expect(chart.index, 0);

      // reorder
      await tester.tap(find.byIcon(Icons.settings_sharp));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(KIcons.reorder));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('reorder.save')));
      await tester.pumpAndSettle();

      // slide date range
      DateTimeRange range = Util.getDateRange(
        now: DateTime.now().subtract(const Duration(days: 7)),
        days: 7,
      );
      expect(find.text(range.format('zh_TW')), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_sharp));
      await tester.pump(const Duration(milliseconds: 50));

      range = Util.getDateRange(
        now: DateTime.now().subtract(const Duration(days: 14)),
        days: 7,
      );
      expect(find.text(range.format('zh_TW')), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_forward_ios_sharp));
      await tester.pump(const Duration(milliseconds: 50));

      range = Util.getDateRange(
        now: DateTime.now().subtract(const Duration(days: 7)),
        days: 7,
      );
      expect(find.text(range.format('zh_TW')), findsOneWidget);

      // select date range
      await tester.tap(find.byKey(const Key('anal.chart_range')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text(range.format('zh_TW')), findsAtLeastNWidgets(1));
    });

    setUpAll(() {
      initializeCache();
      initializeDatabase();
      initializeStorage();
      initializeTranslator();
      VisibilityDetectorController.instance.updateInterval = Duration.zero;
    });
  });
}
