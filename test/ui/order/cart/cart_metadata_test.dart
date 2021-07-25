import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/order/order_product.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/ui/order/cart/cart_metadata.dart';
import 'package:provider/provider.dart';

import '../../../mocks/mock_repos.dart';

void main() {
  testWidgets('should listen cart', (tester) async {
    Cart.instance = Cart();

    await tester.pumpWidget(ChangeNotifierProvider<Cart>.value(
      value: Cart.instance,
      child: MaterialApp(home: CartMetadata()),
    ));

    expect(find.text('total_count-0'), findsOneWidget);
    expect(find.text('total_count-0'), findsOneWidget);

    Cart.instance.add(Product(index: 1, name: 'name', price: 1));
    await tester.pump();

    expect(find.text('total_count-1'), findsOneWidget);
    expect(find.text('total_count-1'), findsOneWidget);

    Cart.instance = cart;
  });

  testWidgets('should listen order product', (tester) async {
    Cart.instance = Cart();

    expect(
      OrderProduct.listeners[OrderProductListenerTypes.count],
      isEmpty,
    );

    await tester.pumpWidget(ChangeNotifierProvider<Cart>.value(
      value: Cart.instance,
      child: MaterialApp(home: CartMetadata()),
    ));

    expect(
      OrderProduct.listeners[OrderProductListenerTypes.count]?.length,
      equals(1),
    );

    Cart.instance = cart;
  });
}
