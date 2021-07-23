import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/models/menu/product_model.dart';
import 'package:possystem/models/order/order_product_model.dart';
import 'package:possystem/models/repository/cart_model.dart';
import 'package:possystem/ui/order/cart/cart_metadata.dart';
import 'package:provider/provider.dart';

import '../../../mocks/mocks.dart';

void main() {
  testWidgets('should listen cart', (tester) async {
    CartModel.instance = CartModel();

    await tester.pumpWidget(ChangeNotifierProvider<CartModel>.value(
      value: CartModel.instance,
      child: MaterialApp(home: CartMetadata()),
    ));

    expect(find.text('total_count-0'), findsOneWidget);
    expect(find.text('total_count-0'), findsOneWidget);

    CartModel.instance.add(ProductModel(index: 1, name: 'name', price: 1));
    await tester.pump();

    expect(find.text('total_count-1'), findsOneWidget);
    expect(find.text('total_count-1'), findsOneWidget);

    CartModel.instance = cart;
  });

  testWidgets('should listen order product', (tester) async {
    CartModel.instance = CartModel();

    expect(
      OrderProductModel.listeners[OrderProductListenerTypes.count],
      isEmpty,
    );

    await tester.pumpWidget(ChangeNotifierProvider<CartModel>.value(
      value: CartModel.instance,
      child: MaterialApp(home: CartMetadata()),
    ));

    expect(
      OrderProductModel.listeners[OrderProductListenerTypes.count]?.length,
      equals(1),
    );

    CartModel.instance = cart;
  });
}
