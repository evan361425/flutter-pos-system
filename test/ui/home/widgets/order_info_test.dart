import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/ui/home/widgets/order_info.dart';

import '../../../mocks/mocks.dart';
import '../../../mocks/providers.dart';

void main() {
  testWidgets('should reset', (tester) async {
    final totalPrice = 50;
    final count = 5;
    var loadCount = 0;
    final orderInfo = GlobalKey<OrderInfoState>();
    when(orders.getMetricBetween()).thenAnswer((_) {
      return Future.value({
        'totalPrice': totalPrice,
        'count': count + loadCount++,
      });
    });
    when(currency.numToString(any)).thenReturn(totalPrice.toString());

    await tester.pumpWidget(MaterialApp(home: OrderInfo(key: orderInfo)));
    await tester.pump();

    expect(find.text('5'), findsOneWidget);

    orderInfo.currentState?.reset();

    await tester.pumpAndSettle();

    expect(find.text('6'), findsOneWidget);
    expect(find.text('5'), findsNothing);
  });

  setUpAll(() {
    initialize();
    initializeProviders();
  });
}
