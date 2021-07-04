import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/components/style/circular_loading.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/ui/analysis/widgets/order_list.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../mocks/mockito/mock_order_object.dart';
import '../../../mocks/providers.dart';

void main() {
  testWidgets('should not load when initialize', (tester) async {
    final orderListState = GlobalKey<OrderListState>();
    var loadCount = 0;

    await tester.pumpWidget(MaterialApp(
      home: OrderList(
          key: orderListState,
          handleLoad: (_, __) {
            loadCount++;
            return Future.delayed(
              Duration(milliseconds: 100),
              () => Future.value([]),
            );
          }),
    ));

    expect(loadCount, equals(0));
    expect(find.byType(CircularLoading), findsNothing);
    expect(find.byType(SmartRefresher), findsNothing);

    orderListState.currentState?.reset({}, totalPrice: 0, totalCount: 0);

    await tester.pump(Duration(milliseconds: 10));

    expect(find.byType(CircularLoading), findsOneWidget);
    expect(loadCount, equals(1));

    await tester.pumpAndSettle();

    // should not set refresher if empty result
    expect(find.byType(SmartRefresher), findsNothing);
    expect(loadCount, equals(1));
  });

  testWidgets('should load more', (tester) async {
    initializeProviders();
    OrderObject createOrder(int count) {
      final order = MockOrderObject();
      when(order.createdAt).thenReturn(DateTime.now());
      when(order.totalPrice).thenReturn(count);
      when(order.paid).thenReturn(0);
      when(order.products).thenReturn([]);

      return order;
    }

    final orderListState = GlobalKey<OrderListState>();
    final data = <OrderObject>[createOrder(1), createOrder(2)];
    var loadCount = 0;
    when(currency.numToString(any)).thenReturn('');

    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: OrderList(
            key: orderListState,
            handleLoad: (_, start) {
              loadCount++;
              if (start == 2) return Future.value([]);
              return Future.value(data.sublist(start, start + 1));
            }),
      ),
    ));

    orderListState.currentState?.reset({}, totalPrice: 0, totalCount: 0);
    await tester.pumpAndSettle();

    expect(loadCount, equals(1));
    expect(find.byType(SmartRefresher), findsOneWidget);

    final center = tester.getCenter(find.byType(SmartRefresher));

    await tester.dragFrom(center, Offset(0, -300));
    await tester.pumpAndSettle();

    expect(loadCount, equals(2));

    await tester.dragFrom(center, Offset(0, -300));
    await tester.pumpAndSettle();

    expect(loadCount, equals(3));

    await tester.dragFrom(center, Offset(0, -300));
    await tester.pumpAndSettle();

    expect(loadCount, equals(3));
  });
}
