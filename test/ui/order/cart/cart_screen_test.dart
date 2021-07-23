import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/menu/product_model.dart';
import 'package:possystem/models/order/order_product_model.dart';
import 'package:possystem/models/repository/cart_model.dart';
import 'package:possystem/ui/order/cart/cart_screen.dart';
import 'package:provider/provider.dart';

import '../../../mocks/mocks.dart';

void main() {
  testWidgets('select all', (tester) async {
    when(cart.products).thenReturn([]);
    when(cart.totalCount).thenReturn(20);
    when(cart.totalPrice).thenReturn(20);
    await tester.pumpWidget(MultiProvider(
      providers: [ChangeNotifierProvider<CartModel>.value(value: cart)],
      child: MaterialApp(home: Material(child: CartScreen())),
    ));

    await tester.tap(find.byType(ElevatedButton).first);

    verify(cart.toggleAll(true));
  });

  testWidgets('toggle all', (tester) async {
    when(cart.products)
        .thenReturn([OrderProductModel(ProductModel(index: 1, name: 'name'))]);
    when(cart.totalCount).thenReturn(20);
    when(cart.totalPrice).thenReturn(20);
    await tester.pumpWidget(MultiProvider(
      providers: [ChangeNotifierProvider<CartModel>.value(value: cart)],
      child: MaterialApp(home: Material(child: CartScreen())),
    ));

    await tester.tap(find.byType(ElevatedButton).last);

    verify(cart.toggleAll(null));
  });

  setUpAll(() {
    initialize();
  });
}
