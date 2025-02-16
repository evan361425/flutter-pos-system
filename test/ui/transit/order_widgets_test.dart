import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/order_widgets.dart';

import '../../mocks/mock_database.dart';
import '../../test_helpers/order_setter.dart';
import '../../test_helpers/translator.dart';

void main() {
  group('Transit Order List', () {
    Future<void> showDialog(WidgetTester tester, IconData icon) async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final range = DateTimeRange(start: yesterday, end: DateTime.now());
      final widget = TransitOrderList(
        leading: const Text(''),
        ranger: ValueNotifier(range),
        orderViewBuilder: (o) => const Text('hi'),
        memoryPredictor: (m) => m.revenue.toInt(),
        warning: 'hi there',
      );

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

    setUpAll(() {
      initializeDatabase();
      initializeTranslator();
    });
  });
}
