import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/models/menu/product_ingredient_model.dart';
import 'package:possystem/models/menu/product_model.dart';
import 'package:possystem/models/menu/product_quantity_model.dart';
import 'package:possystem/models/order/order_product_model.dart';
import 'package:possystem/models/repository/cart_model.dart';
import 'package:possystem/models/stock/ingredient_model.dart';
import 'package:possystem/models/stock/quantity_model.dart';
import 'package:possystem/ui/order/cart/cart_product_list.dart';
import 'package:provider/provider.dart';

void main() {
  OrderProductModel createProduct(String name,
      [String? ingName, String? quaName]) {
    final product = ProductModel(id: name, name: name);

    final ingredient = ingName == null
        ? null
        : ProductIngredientModel(
            ingredient: IngredientModel(name: ingName, id: ingName),
            product: product);
    final quantity = quaName == null
        ? null
        : ProductQuantityModel(
            quantity: QuantityModel(name: quaName, id: quaName),
            ingredient: ingredient);
    if (quantity != null) {
      ingredient?.replaceItems({quaName!: quantity});
    }
    if (ingredient != null) {
      product.replaceItems({ingName!: ingredient});
    }

    return OrderProductModel(product);
  }

  testWidgets('select target when tap tile', (tester) async {
    final cart = CartModel();
    final product1 = createProduct('pro-1');
    final product2 = createProduct('pro-2', 'ing-1', 'qua-1');
    product1.isSelected = true;

    cart.products = [product1, product2];

    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: cart,
      child: MaterialApp(home: Material(child: CartProductList())),
    ));

    expect(product1.isSelected, isTrue);
    expect(product2.isSelected, isFalse);

    await tester.tap(find.text('pro-2'));
    await tester.pump();

    expect(product1.isSelected, isFalse);
    expect(product2.isSelected, isTrue);
  });

  testWidgets('toggle target when tap checkbox', (tester) async {
    final cart = CartModel();
    final product1 = createProduct('pro-1');
    final product2 = createProduct('pro-2');
    product1.isSelected = true;

    cart.products = [product1, product2];

    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: cart,
      child: MaterialApp(home: Material(child: CartProductList())),
    ));

    expect(product1.isSelected, isTrue);
    expect(product2.isSelected, isFalse);

    await tester.tap(find.byType(Checkbox).last);
    await tester.pump();

    expect(product1.isSelected, isTrue);
    expect(product2.isSelected, isTrue);
  });

  testWidgets('change money and count when add', (tester) async {
    final cart = CartModel();
    final product = createProduct('pro-1');

    product.singlePrice = 20;
    product.count = 2;
    cart.products = [product];

    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: cart,
      child: MaterialApp(home: Material(child: CartProductList())),
    ));

    await tester.tap(find.byType(IconButton));
    await tester.pump();

    expect(product.price, equals(60));
  });
}
