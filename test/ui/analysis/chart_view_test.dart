import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/models/analysis/analysis.dart';
import 'package:possystem/models/analysis/chart.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/ui/analysis/widgets/chart_card_view.dart';

void main() {
  group('Chart View', () {
    Widget buildApp<T>(Chart<T> chart) {
      return Scaffold(
        body: ChartCardView<T>(chart: chart),
      );
    }

    group('Cartesian Chart', () {
      testWidgets('edit to product without selection', (tester) async {
        Menu().replaceItems({
          'c1': Catalog(id: 'c1', name: 'c1')
            ..replaceItems({
              'p1': Product(id: 'p1', name: 'p1'),
              'p2': Product(id: 'p2', name: 'p2'),
            }),
        });

        await tester.pumpWidget(buildApp(CartesianChart(id: 'test')));
        await tester.tap(find.byKey(const Key('chart.test.more')));
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key('chart.title')), 'title2');
        await tester.tap(find.byKey(const Key('chart.withToday')));
        await tester.tap(find.byKey(const Key('chart.ignoreEmpty')));
        await tester.tap(find.byKey(const Key('chart.range.today')));
        await tester.tap(find.byKey(const Key('chart.type.cartesian')));
        await tester.tap(find.byKey(const Key('chart.target.product')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('chart.item.p2')));
        await tester.tap(find.byKey(const Key('chart.item.p2'))); // cancel
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('chart.save')));
      });

      testWidgets('edit to attributes with selection', (tester) async {
        await tester.pumpWidget(buildApp(CartesianChart(
          target: OrderMetricTarget.product,
        )));
      });

      testWidgets('show 1 day dynamically with today', (tester) async {});

      testWidgets('show 1 day with all type of metrics', (tester) async {});

      testWidgets('show 7 day with empty', (tester) async {});

      testWidgets('show 365 day without empty', (tester) async {});
    });

    group('Circular Chart', () {
      testWidgets('edit', (tester) async {
        buildApp(CartesianChart());
      });

      testWidgets('show 1 day dynamically with today', (tester) async {});

      testWidgets('show 7 day group to 5', (tester) async {});
    });
  });
}
