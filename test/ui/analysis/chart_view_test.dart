import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/analysis/analysis.dart';
import 'package:possystem/models/analysis/chart.dart';
import 'package:possystem/models/analysis/chart_object.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/order/order_attribute.dart';
import 'package:possystem/models/order/order_attribute_option.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/analysis/widgets/chart_card_view.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../mocks/mock_database.dart';
import '../../mocks/mock_storage.dart';
import '../../test_helpers/translator.dart';

void main() {
  group('Chart View', () {
    Widget buildApp<T>(Chart<T> chart) {
      Analysis().replaceItems({chart.id: chart});
      final view = ChartCardView<T>(chart: chart);
      return MaterialApp.router(
        routerConfig: GoRouter(routes: [
          GoRoute(
            path: '/',
            routes: Routes.routes,
            builder: (ctx, state) {
              return Scaffold(body: view);
            },
          ),
        ]),
      );
    }

    void mockGetItemMetricsInPeriod({
      Matcher? table,
      Matcher? columns,
      OrderMetricTarget? target,
      List<Map<String, Object?>> rows = const [],
    }) {
      when(database.query(
        argThat(table ?? anything),
        columns: argThat(columns ?? anything, named: 'columns'),
        groupBy: argThat(
          target == null ? anything : equals("t.day, ${target.groupColumn}"),
          named: 'groupBy',
        ),
        orderBy: anyNamed('orderBy'),
        escapeTable: anyNamed('escapeTable'),
      )).thenAnswer((_) async => rows);
    }

    void mockGetMetricsInPeriod({
      Matcher? table,
      Matcher? columns,
      List<Map<String, Object?>> rows = const [],
    }) {
      when(database.query(
        argThat(table ?? anything),
        columns: argThat(columns ?? anything, named: 'columns'),
        groupBy: argThat(equals("t.day"), named: 'groupBy'),
        orderBy: anyNamed('orderBy'),
        escapeTable: anyNamed('escapeTable'),
      )).thenAnswer((_) async => rows);
    }

    group('Cartesian Chart', () {
      testWidgets('edit to product with selection', (tester) async {
        final today = Util.toUTC(hour: 0);
        final yesterday = today - 86400;
        final tomorrow = today + 86400;
        final sevenDaysAgo = today - 86400 * 7;
        Menu().replaceItems({
          'c1': Catalog(id: 'c1', name: 'c1')
            ..replaceItems({
              'p1': Product(id: 'p1', name: 'p1'),
              'p2': Product(id: 'p2', name: 'p2'),
            }),
        });
        mockGetMetricsInPeriod(
            table: equals(
                '(SELECT CAST((createdAt - $sevenDaysAgo) / 86400 AS INT) day, * FROM order_records WHERE createdAt BETWEEN $sevenDaysAgo AND $today) t'),
            rows: [
              {
                'day': 1,
                'price': 1.1,
                'revenue': 2.2,
              },
              {'day': 3, 'price': 1.2, 'revenue': 2.3},
            ]);

        await tester.pumpWidget(buildApp(CartesianChart(id: 'test')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('chart.test.more')));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(KIcons.modal));
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key('chart.title')), 'title2');
        await tester.tap(find.byKey(const Key('chart.withToday')));
        await tester.tap(find.byKey(const Key('chart.ignoreEmpty')));
        await tester.tap(find.byKey(const Key('chart.range.today')));
        await tester.tap(find.byKey(const Key('chart.type.circular')));
        await tester.tap(find.byKey(const Key('chart.type.cartesian')));
        await tester.dragFrom(const Offset(500, 500), const Offset(0, -500));
        await tester.tap(find.byKey(const Key('chart.metrics.count')));
        await tester.pumpAndSettle();

        final selected = OrderMetricType.values.map((type) {
          final chip = find.byKey(Key('chart.metrics.${type.name}')).evaluate();
          return (chip.single.widget as ChoiceChip).selected;
        });
        expect(selected.where((e) => e).length, equals(3));

        await tester.dragFrom(const Offset(500, 500), const Offset(0, -500));
        await tester.tap(find.byKey(const Key('chart.target.product')));
        await tester.pumpAndSettle();
        expect(selected.where((e) => e).isEmpty, equals(true));

        await tester.dragFrom(const Offset(500, 500), const Offset(0, -500));
        await tester.tap(find.byKey(const Key('chart.item.p2')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('chart.item_all')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('chart.item.p2')));
        await tester.pumpAndSettle();

        // withToday is true so the range should contain tomorrow: yesterday < t < tomorrow
        mockGetItemMetricsInPeriod(
          table: equals(
              '(SELECT CAST((createdAt - $yesterday) / 3600 AS INT) day, * FROM order_products WHERE createdAt BETWEEN $yesterday AND $tomorrow  AND productName IN ("p2") ) t'),
          target: OrderMetricTarget.product,
          rows: [
            {'day': 1, 'name': 'p2', 'count': 1},
            {'day': 3, 'name': 'p2', 'count': 3},
          ],
        );

        await tester.tap(find.byKey(const Key('modal.save')));
        await tester.pumpAndSettle();

        expect(find.text('title2'), findsOneWidget);
        expect(find.text('p2', findRichText: true), findsOneWidget);
        // `p1` should not exist only if selection not contains it.
        expect(find.text('p1', findRichText: true), findsNothing);

        verify(storage.set(
          any,
          argThat(equals(<String, Object?>{
            'test.name': 'title2',
            'test.metrics': [],
            'test.target': OrderMetricTarget.product.index,
            'test.selection': ['p2'],
            'test.withToday': true,
            'test.ignoreEmpty': true,
            'test.range': OrderChartRange.today.index,
          })),
        ));
      });

      testWidgets('edit to attributes without selection', (tester) async {
        final today = Util.toUTC(hour: 0);
        final sevenDaysAgo = today - 86400 * 7;
        OrderAttributes().replaceItems({
          'a1': OrderAttribute(id: 'a1', name: 'a1')
            ..replaceItems({
              'a1o1': OrderAttributeOption(id: 'a1o1', name: 'o1'),
              'a1o2': OrderAttributeOption(id: 'a1o2', name: 'o2'),
            })
            ..prepareItem(),
          'a2': OrderAttribute(id: 'a2', name: 'a2')
            ..replaceItems({
              'a2o1': OrderAttributeOption(id: 'a2o1', name: 'o1'),
              'a2o2': OrderAttributeOption(id: 'a2o2', name: 'o2'),
            })
            ..prepareItem(),
        });
        mockGetMetricsInPeriod();

        await tester.pumpWidget(buildApp(CartesianChart(id: 'test')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('chart.test.more')));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(KIcons.modal));
        await tester.pumpAndSettle();

        await tester.dragFrom(const Offset(500, 500), const Offset(0, -500));
        await tester.tap(find.byKey(const Key('chart.target.attribute')));
        await tester.pumpAndSettle();

        // withToday is true so the range should contain tomorrow: yesterday < t < tomorrow
        mockGetItemMetricsInPeriod(
          table: equals(
              '(SELECT CAST((createdAt - $sevenDaysAgo) / 86400 AS INT) day, * FROM order_attributes WHERE createdAt BETWEEN $sevenDaysAgo AND $today  ) t'),
          target: OrderMetricTarget.attribute,
        );

        await tester.tap(find.byKey(const Key('modal.save')));
        await tester.pumpAndSettle();

        // all item should exist if select all.
        expect(find.text('o1(a1)', findRichText: true), findsOneWidget);
        expect(find.text('o2(a1)', findRichText: true), findsOneWidget);
        expect(find.text('o1(a2)', findRichText: true), findsOneWidget);
        expect(find.text('o2(a2)', findRichText: true), findsOneWidget);

        verify(storage.set(
          any,
          argThat(equals(<String, Object?>{
            'test.metrics': [],
            'test.target': OrderMetricTarget.attribute.index,
          })),
        ));
      });

      testWidgets('slide the range with price and count', (tester) async {
        final today = Util.toUTC(hour: 0);
        final sevenDaysAgo = today - 86400 * 7;
        final fourteenDaysAgo = today - 86400 * 14;
        mockGetMetricsInPeriod(rows: [
          {'day': 1, 'price': 1.1, 'count': 2},
          {'day': 2, 'price': 2.2, 'count': 3},
        ]);

        await tester.pumpWidget(buildApp(CartesianChart(
          id: 'test',
          metrics: [OrderMetricType.price, OrderMetricType.count],
        )));
        await tester.pumpAndSettle();

        void verifyContains(int days) {
          verify(database.query(
            argThat(contains('$days')),
            columns: anyNamed('columns'),
            groupBy: anyNamed('groupBy'),
            orderBy: anyNamed('orderBy'),
            escapeTable: anyNamed('escapeTable'),
          )).called(1);
        }

        verifyContains(sevenDaysAgo);

        await tester.tap(find.byIcon(Icons.arrow_back_ios_new_sharp));
        await tester.pumpAndSettle();
        verifyContains(fourteenDaysAgo);

        await tester.tap(find.byIcon(Icons.arrow_forward_ios_sharp));
        await tester.pumpAndSettle();
        verifyContains(sevenDaysAgo);

        // after today is not searchable
        await tester.tap(find.byIcon(Icons.arrow_forward_ios_sharp));
        await tester.pumpAndSettle();
        verifyNever(database.query(
          any,
          columns: anyNamed('columns'),
          groupBy: anyNamed('groupBy'),
          orderBy: anyNamed('orderBy'),
          escapeTable: anyNamed('escapeTable'),
        ));

        await tester.tap(find.byIcon(Icons.refresh_sharp));
        await tester.pumpAndSettle();
        verifyContains(sevenDaysAgo);
      });

      testWidgets('365 day with all types and ignore drag', (tester) async {
        mockGetMetricsInPeriod(rows: [
          {'day': 1, 'price': 1.1, 'revenue': 1.1, 'cost': 1.1, 'count': 2},
          {'day': 2, 'price': 2.2, 'revenue': 2.2, 'cost': 2.2, 'count': 3},
        ]);

        final chart = CartesianChart(
          id: 'test',
          metrics: OrderMetricType.values,
          range: OrderChartRange.year,
          ignoreEmpty: true,
        );
        Analysis().replaceItems({chart.id: chart});
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                SizedBox(width: 300, child: ChartCardView(chart: chart)),
                const SizedBox(width: 2000, height: 200),
              ]),
            ),
          ),
        ));
        await tester.pumpAndSettle();

        final charts = find.byType(SfCartesianChart).evaluate();
        expect(charts.length, equals(1));
        final axes = (charts.first.widget as SfCartesianChart).axes;
        expect(axes.length, equals(2));
        expect(axes.first.name, equals(OrderMetricUnit.money.name));
        expect(axes.elementAt(1).name, equals(OrderMetricUnit.count.name));

        // drag will be ignored to avoid TabView scrolling
        await tester.dragFrom(const Offset(250, 300), const Offset(-200, 0));
      });
    });

    void mockGetMetricsByItems({
      Matcher? table,
      Matcher? where,
      Matcher? whereArgs,
      Matcher? groupBy,
      List<Map<String, Object?>> rows = const [],
    }) {
      when(database.query(
        argThat(table ?? anything),
        columns: anyNamed('columns'),
        where: argThat(where ?? anything, named: 'where'),
        whereArgs: argThat(whereArgs ?? anything, named: 'whereArgs'),
        groupBy: argThat(groupBy ?? anything, named: 'groupBy'),
        orderBy: anyNamed('orderBy'),
      )).thenAnswer((_) async => rows);
    }

    group('Circular Chart', () {
      testWidgets('edit to attribute with selection', (tester) async {
        Stock().replaceItems({
          'i1': Ingredient(id: 'i1', name: 'i1'),
          'i2': Ingredient(id: 'i2', name: 'i2'),
        });
        OrderAttributes().replaceItems({
          'a1': OrderAttribute(id: 'a1', name: 'a1')
            ..replaceItems({
              'a1o1': OrderAttributeOption(id: 'a1o1', name: 'a1o1'),
              'a1o2': OrderAttributeOption(id: 'a1o2', name: 'a1o2'),
            })
            ..prepareItem(),
          'a2': OrderAttribute(id: 'a2', name: 'a2')
            ..replaceItems({
              'a2o1': OrderAttributeOption(id: 'a2o1', name: 'a2o1'),
              'a2o2': OrderAttributeOption(id: 'a2o2', name: 'a2o2'),
              'a2o3': OrderAttributeOption(id: 'a2o3', name: 'a2o3'),
            })
            ..prepareItem(),
        });
        mockGetMetricsByItems(
          table: equals(OrderMetricTarget.ingredient.table),
          where: equals('createdAt BETWEEN ? AND ?'),
          rows: [
            {'name': 'i1', 'value': 1},
          ],
        );

        await tester.pumpWidget(buildApp(CircularChart(
          id: 'test',
          target: OrderMetricTarget.ingredient,
          ignoreEmpty: true,
        )));
        await tester.pumpAndSettle();

        expect(find.text('i1', findRichText: true), findsOneWidget);
        expect(find.text('i2', findRichText: true), findsNothing);

        await tester.tap(find.byKey(const Key('chart.test.more')));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(KIcons.modal));
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key('chart.groupTo')), '1');
        await tester.tap(find.byKey(const Key('chart.ignoreEmpty')));
        await tester.dragFrom(const Offset(500, 500), const Offset(0, -500));
        await tester.tap(find.byKey(const Key('chart.target.attribute')));
        await tester.pumpAndSettle();

        await tester.dragFrom(const Offset(500, 500), const Offset(0, -500));
        await tester.tap(find.byKey(const Key('chart.item.a1')));
        await tester.tap(find.byKey(const Key('chart.item.a2')));
        await tester.pumpAndSettle();

        // only one selected
        mockGetMetricsByItems(
          table: equals(OrderMetricTarget.attribute.table),
          where: equals('createdAt BETWEEN ? AND ? AND name IN ("a2")'),
          rows: [
            {'name': 'a2o1', 'value': 2},
            {'name': 'a2o2', 'value': 1},
          ],
        );

        await tester.tap(find.byKey(const Key('modal.save')));
        await tester.pumpAndSettle();

        expect(find.text('a2o1', findRichText: true), findsOneWidget);
        // group to others
        expect(find.text('a2o2', findRichText: true), findsNothing);
        expect(find.text('a2o3', findRichText: true), findsNothing);
        expect(find.text('Others', findRichText: true), findsOneWidget);

        verify(storage.set(
          any,
          argThat(equals(<String, Object?>{
            'test.target': OrderMetricTarget.attribute.index,
            'test.selection': ['a2'],
            'test.ignoreEmpty': false,
            'test.groupTo': 1,
          })),
        ));
      });

      testWidgets('slide date range', (tester) async {
        final today = Util.toUTC(hour: 0);
        final yesterday = today - 86400;
        final twoDaysAgo = yesterday - 86400;
        final tomorrow = today + 86400;
        Menu().replaceItems({
          'c1': Catalog(id: 'c1', name: 'c1'),
          'c2': Catalog(id: 'c2', name: 'c2'),
        });
        mockGetMetricsByItems(
          whereArgs: equals([yesterday, tomorrow]),
          rows: [
            {'name': 'c1', 'value': 1},
          ],
        );
        mockGetMetricsByItems(whereArgs: equals([twoDaysAgo, yesterday]));

        await tester.pumpWidget(buildApp(CircularChart(
          id: 'test',
          target: OrderMetricTarget.catalog,
          range: OrderChartRange.today,
          ignoreEmpty: true,
          withToday: true,
          groupTo: 0,
        )));
        await tester.pumpAndSettle();

        expect(find.text('c1', findRichText: true), findsOneWidget);
        expect(find.text('c2', findRichText: true), findsNothing);

        await tester.tap(find.byIcon(Icons.arrow_back_ios_new_sharp));
        await tester.pumpAndSettle();

        verify(database.query(
          any,
          columns: anyNamed('columns'),
          where: anyNamed('where'),
          whereArgs: argThat(equals([yesterday, tomorrow]), named: 'whereArgs'),
          groupBy: anyNamed('groupBy'),
          orderBy: anyNamed('orderBy'),
        ));
      });

      testWidgets('group to 2 values but show all if all same', (tester) async {
        Menu().replaceItems({
          'c1': Catalog(id: 'c1', name: 'c1'),
          'c2': Catalog(id: 'c2', name: 'c2'),
          'c3': Catalog(id: 'c3', name: 'c3'),
          'c4': Catalog(id: 'c4', name: 'c4'),
        });
        mockGetMetricsByItems(
          rows: [
            {'name': 'c1', 'value': 3},
            // {'name': 'c2', 'value': 1},
            // {'name': 'c3', 'value': 1},
            // {'name': 'c4', 'value': 1},
          ],
        );

        await tester.pumpWidget(buildApp(CircularChart(
          id: 'test',
          target: OrderMetricTarget.catalog,
          ignoreEmpty: false,
          groupTo: 2,
        )));
        await tester.pumpAndSettle();

        expect(find.text('c1', findRichText: true), findsOneWidget);
        expect(find.text('c2', findRichText: true), findsOneWidget);
        expect(find.text('c3', findRichText: true), findsOneWidget);
        expect(find.text('c4', findRichText: true), findsOneWidget);
      });
    });
  });

  setUpAll(() {
    initializeDatabase();
    initializeStorage();
    initializeTranslator();
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  tearDown(() {
    reset(database);
    reset(storage);
  });
}
