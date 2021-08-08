import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/components/radio_text.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/order/order_ingredient.dart';
import 'package:possystem/models/order/order_product.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/ui/order/widgets/order_ingredient_list.dart';

import '../../../mocks/mock_repos.dart';

void main() {
  testWidgets('show empty when no products', (tester) async {
    when(cart.isEmpty).thenReturn(true);

    await tester.pumpWidget(MaterialApp(home: OrderIngredientList()));

    expect(find.text('cart_empty'), findsOneWidget);
  });

  testWidgets('show empty when no same selected products', (tester) async {
    when(cart.isEmpty).thenReturn(false);
    when(cart.isSameProducts).thenReturn(false);

    await tester.pumpWidget(MaterialApp(home: OrderIngredientList()));

    expect(find.text('not_same_product'), findsOneWidget);
  });

  testWidgets('show empty when no able ingredients', (tester) async {
    final product = Product(index: 1, name: 'name', price: 20);
    when(cart.isEmpty).thenReturn(false);
    when(cart.isSameProducts).thenReturn(true);
    when(cart.selected).thenReturn([OrderProduct(product)]);
    when(cart.products).thenReturn([OrderProduct(product)]);

    await tester.pumpWidget(MaterialApp(home: OrderIngredientList()));

    expect(find.text('no_quantity'), findsOneWidget);
  });

  ProductIngredient createIngredient(String name, List<String> quantityNames) {
    final ingredient = Ingredient(name: name, id: name);
    final proIngredient = ProductIngredient(ingredient: ingredient);
    final quantities = quantityNames.map<ProductQuantity>((e) {
      final quantity = Quantity(name: e, id: e);
      return ProductQuantity(quantity: quantity, ingredient: proIngredient);
    });

    proIngredient
        .replaceItems({for (var quantity in quantities) quantity.id: quantity});

    return proIngredient;
  }

  testWidgets('show quantity in selected ingredient', (tester) async {
    final product = Product(index: 1, name: 'pro', id: 'pro');
    final ingredients = [
      createIngredient('ing-1', ['qua-1']),
      createIngredient('ing-2', ['qua-2']),
    ].map((e) {
      e.product = product;
      return e;
    }).toList();
    product.replaceItems({for (var ing in ingredients) ing.id: ing});
    when(cart.isEmpty).thenReturn(false);
    when(cart.isSameProducts).thenReturn(true);
    when(cart.selected).thenReturn([OrderProduct(product)]);
    when(cart.products).thenReturn([OrderProduct(product)]);
    when(cart.getSelectedQuantityId(ingredients[0])).thenReturn(null);
    when(cart.getSelectedQuantityId(ingredients[1])).thenReturn('qua-2');

    await tester.pumpWidget(MaterialApp(home: OrderIngredientList()));

    expect(find.text('qua-1（0）'), findsOneWidget);

    await tester.tap(find.text('ing-2'));
    await tester.pump();

    expect(find.text('qua-2（0）'), findsOneWidget);
  });

  testWidgets('should update selected quantity', (tester) async {
    final product = Product(index: 1, name: 'pro', id: 'pro');
    final ingredients = [
      createIngredient('ing-1', ['qua-1'])
    ].map((e) {
      e.product = product;
      return e;
    }).toList();
    product.replaceItems({for (var ing in ingredients) ing.id: ing});
    when(cart.isEmpty).thenReturn(false);
    when(cart.isSameProducts).thenReturn(true);
    when(cart.selected).thenReturn([OrderProduct(product)]);
    when(cart.products).thenReturn([OrderProduct(product)]);
    when(cart.getSelectedQuantityId(ingredients[0])).thenReturn(null);

    await tester.pumpWidget(MaterialApp(home: OrderIngredientList()));

    await tester.tap(find.text('qua-1（0）'));
    await tester.pump();

    verify(cart.updateSelectedIngredient(argThat(predicate<OrderIngredient>(
        (ing) => identical(ing.ingredient, ingredients[0])))));
  });

  setUpAll(() {
    initializeRepos();
  });

  tearDown(() {
    RadioText.clearAll();
  });
}
