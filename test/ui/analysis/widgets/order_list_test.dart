import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/circular_loading.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/ui/analysis/widgets/analysis_order_list.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../mocks/mock_models.mocks.dart';
import '../../../mocks/mock_providers.dart';

void main() {
  testWidgets('should not load when initialize', (tester) async {
    final orderListState = GlobalKey<AnalysisOrderListState>();
    var loadCount = 0;

    await tester.pumpWidget(MaterialApp(
      home: AnalysisOrderList(
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

    final orderListState = GlobalKey<AnalysisOrderListState>();
    final data = <OrderObject>[createOrder(1), createOrder(2)];
    var loadCount = 0;
    when(currency.numToString(any)).thenReturn('');

    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: AnalysisOrderList(
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

  testWidgets('should navigate to modal', (tester) async {
    final order = MockOrderObject();
    final pro1 = OrderProductObject(
        singlePrice: 1,
        originalPrice: 2,
        count: 3,
        productId: 'pro1',
        productName: 'pro1',
        isDiscount: true,
        ingredients: {});
    final pro2 = OrderProductObject(
        singlePrice: 1,
        originalPrice: 1,
        count: 1,
        productId: 'pro2',
        productName: 'pro2',
        isDiscount: false,
        ingredients: {});
    when(order.createdAt).thenReturn(DateTime.now());
    when(order.totalPrice).thenReturn(4);
    when(order.paid).thenReturn(5);
    when(order.products).thenReturn([pro1, pro2]);

    final orderListState = GlobalKey<AnalysisOrderListState>();
    when(currency.numToString(any)).thenReturn('');

    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: AnalysisOrderList(
            key: orderListState,
            handleLoad: (_, __) => Future.value(<OrderObject>[order])),
      ),
    ));

    orderListState.currentState?.reset({}, totalPrice: 0, totalCount: 0);
    await tester.pumpAndSettle();

    await tester.tap(find.text(['pro1 * 3', 'pro2'].join(MetaBlock.string)));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(KIcons.back));
    await tester.pumpAndSettle();
  });

  setUpAll(() {
    initializeProviders();
  });
}
