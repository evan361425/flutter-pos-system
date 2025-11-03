import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/formatter/formatter.dart';
import 'package:possystem/ui/transit/order_widgets.dart';
import 'package:possystem/ui/transit/widgets.dart';

import '../../mocks/mock_cache.dart';
import '../../mocks/mock_database.dart';
import '../../test_helpers/order_setter.dart';
import '../../test_helpers/translator.dart';

void main() {
  group('Transit Order List', () {
    Future<void> showDialog(WidgetTester tester, IconData icon) async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final range = DateTimeRange(start: yesterday, end: DateTime.now());
      final widget = _TestOrderList(ranger: ValueNotifier(range));

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(icon));
      await tester.pumpAndSettle();
    }

    testWidgets('memory usage show ok', (tester) async {
      final order = OrderSetter.sample(price: 0);
      OrderSetter.setMetrics([order], countingAll: true);
      OrderSetter.setOrders([order]);

      await showDialog(tester, Icons.check_outlined);

      expect(find.text(S.transitOrderCapacityTitle('<1KB')), findsOneWidget);
    });

    testWidgets('memory usage show warning', (tester) async {
      final order = OrderSetter.sample(price: 700 * 1024);
      OrderSetter.setMetrics([order], countingAll: true);
      OrderSetter.setOrders([order]);

      await showDialog(tester, Icons.warning_amber_outlined);

      expect(find.text(S.transitOrderCapacityTitle('700KB')), findsOneWidget);
    });

    testWidgets('memory usage show danger', (tester) async {
      final order = OrderSetter.sample(price: 1.5 * 1024 * 1024);
      OrderSetter.setMetrics([order], countingAll: true);
      OrderSetter.setOrders([order]);

      await showDialog(tester, Icons.dangerous_outlined);

      expect(find.text(S.transitOrderCapacityTitle('1.5MB')), findsOneWidget);
    });

    testWidgets('preview order', (tester) async {
      final order = OrderSetter.sample();
      OrderSetter.setMetrics([order], countingAll: true);
      OrderSetter.setOrders([order]);
      OrderSetter.setOrder(order);

      await showDialog(tester, Icons.expand_outlined);

      expect(find.byType(Table), findsNWidgets(4));
    });

    testWidgets('edit metadata and range', (tester) async {
      cache.reset();
      when(cache.get(any)).thenReturn(null);
      when(cache.set(any, any)).thenAnswer((_) async => true);
      OrderSetter.setMetrics([], countingAll: true);
      OrderSetter.setOrders([]);

      final ranger = ValueNotifier(DateTimeRange(
        start: DateTime(2023, DateTime.june, 10),
        end: DateTime(2023, DateTime.june, 11),
      ));
      final settings = ValueNotifier(const TransitOrderSettings());
      final list = _TestOrderList(ranger: ranger);

      expect(list.warningMessage, isNull);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: [
            _TestOrderHeader(
              stateNotifier: TransitStateNotifier(),
              ranger: ranger,
              settings: settings,
            ),
            list,
          ]),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.date_range_outlined));
      await tester.pumpAndSettle();

      // date range: xx/01 - xx/05
      await tester.tap(find.text('1').first);
      await tester.tap(find.text('5').first);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(
          ranger.value.toString(),
          equals(DateTimeRange(
            start: DateTime(2023, DateTime.june, 1),
            end: DateTime(2023, DateTime.june, 6),
          ).toString()));

      await tester.tap(find.byIcon(Icons.settings_sharp));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('transit.order.is_overwrite')));
      await tester.pumpAndSettle();

      expect(find.text(S.transitOrderSettingRecommendCombination), findsOneWidget);

      await tester.tap(find.byKey(const Key('transit.order.with_prefix')));
      await tester.tap(find.byKey(const Key('modal.save')));
      await tester.pumpAndSettle();

      expect(settings.value.withPrefix, isFalse);
      expect(settings.value.isOverwrite, isFalse);
      verify(cache.set('exporter_order_meta.isOverwrite', false)).called(1);
      verify(cache.set('exporter_order_meta.withPrefix', false)).called(1);
      verify(cache.set('exporter_order_meta.selectedColumns', [0, 1, 2, 3])).called(1);
    });

    testWidgets('edit column selection', (tester) async {
      cache.reset();
      when(cache.get(any)).thenReturn(null);
      when(cache.set(any, any)).thenAnswer((_) async => true);
      OrderSetter.setMetrics([], countingAll: true);
      OrderSetter.setOrders([]);

      final ranger = ValueNotifier(DateTimeRange(
        start: DateTime(2023, DateTime.june, 10),
        end: DateTime(2023, DateTime.june, 11),
      ));
      final settings = ValueNotifier(const TransitOrderSettings());

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: [
            _TestOrderHeader(
              stateNotifier: TransitStateNotifier(),
              ranger: ranger,
              settings: settings,
            ),
          ]),
        ),
      ));
      await tester.pumpAndSettle();

      // Open settings dialog
      await tester.tap(find.byIcon(Icons.settings_sharp));
      await tester.pumpAndSettle();

      // Verify all columns are initially selected
      expect(find.byKey(const Key('transit.order.column.basic')), findsOneWidget);
      expect(find.byKey(const Key('transit.order.column.attr')), findsOneWidget);
      expect(find.byKey(const Key('transit.order.column.product')), findsOneWidget);
      expect(find.byKey(const Key('transit.order.column.ingredient')), findsOneWidget);

      // Deselect 'attr' column
      await tester.tap(find.byKey(const Key('transit.order.column.attr')));
      await tester.pumpAndSettle();

      // Deselect 'ingredient' column
      await tester.tap(find.byKey(const Key('transit.order.column.ingredient')));
      await tester.pumpAndSettle();

      // Save settings
      await tester.tap(find.byKey(const Key('modal.save')));
      await tester.pumpAndSettle();

      // Verify only basic and product columns are selected
      expect(settings.value.selectedColumns.length, equals(2));
      expect(settings.value.selectedColumns.contains(FormattableOrder.basic), isTrue);
      expect(settings.value.selectedColumns.contains(FormattableOrder.product), isTrue);
      verify(cache.set('exporter_order_meta.selectedColumns', [0, 2])).called(1);
    });

    setUpAll(() {
      initializeCache();
      initializeDatabase();
      initializeTranslator();
    });
  });
}

class _TestOrderList extends TransitOrderList {
  const _TestOrderList({required super.ranger});

  @override
  int memoryPredictor(OrderMetrics metrics) => _memoryPredictor(metrics);

  /// Offset are headers
  static int _memoryPredictor(OrderMetrics m) {
    return m.revenue.toInt();
  }
}

class _TestOrderHeader extends TransitOrderHeader {
  const _TestOrderHeader({
    required super.stateNotifier,
    required super.ranger,
    super.settings,
  });

  @override
  Future<void> onExport(BuildContext context, List<OrderObject> orders) async {
    return;
  }

  @override
  String get title => 'Test';
}
