import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/menu/catalog_model.dart';
import 'package:possystem/models/menu/product_ingredient_model.dart';
import 'package:possystem/models/menu/product_model.dart';
import 'package:possystem/models/menu/product_quantity_model.dart';
import 'package:possystem/models/stock/ingredient_model.dart';
import 'package:possystem/models/stock/quantity_model.dart';
import 'package:possystem/ui/order/cashier/calculator_dialog.dart';
import 'package:possystem/ui/order/order_screen.dart';

import '../../mocks/mocks.dart';
import '../../mocks/providers.dart';

void main() {
  testWidgets('should show actions', (tester) async {
    when(menu.setUpStockMode(any)).thenReturn(false);

    await tester.pumpWidget(MaterialApp(home: OrderScreen()));

    await tester.tap(find.byIcon(KIcons.more));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.cancel_sharp), findsOneWidget);
  });

  testWidgets('should show dialog when order', (tester) async {
    when(menu.setUpStockMode(any)).thenReturn(false);
    when(currency.isInt).thenReturn(true);

    await tester.pumpWidget(MaterialApp(home: OrderScreen()));

    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    expect(find.byType(CalculatorDialog), findsOneWidget);
  });

  testWidgets('should buildable in landscape mode', (tester) async {
    when(menu.setUpStockMode(any)).thenReturn(true);
    when(menu.itemList).thenReturn([]);

    const WIDTH = 1800.0;
    const HEIGHT = 1000.0;

    tester.binding.window.physicalSizeTestValue = Size(WIDTH, HEIGHT);

    // resets the screen to its orinal size after the test end
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

    await tester.pumpWidget(MaterialApp(home: OrderScreen()));
  });

  testWidgets('should update products when select catalog', (tester) async {
    final ingredient = IngredientModel(name: 'ing-1', id: 'ing-1');
    final quantity = QuantityModel(name: 'qua-1', id: 'qua-1');
    final proQuantity = ProductQuantityModel(quantity: quantity);
    final proIngredient = ProductIngredientModel(
      ingredient: ingredient,
      quantities: {'qua-1': proQuantity},
    );
    final product1 = ProductModel(
      index: 1,
      name: 'pro-1',
      id: 'pro-1',
      ingredients: {'ing-1': proIngredient},
    );
    final product2 = ProductModel(index: 1, name: 'pro-2', id: 'pro-2');
    final catalog1 = CatalogModel(
      index: 1,
      name: 'cat-1',
      id: 'cat-1',
      products: {'pro-1': product1},
    );
    final catalog2 = CatalogModel(
      index: 1,
      name: 'cat-2',
      id: 'cat-2',
      products: {'pro-2': product2},
    );
    when(menu.setUpStockMode(any)).thenReturn(true);
    when(menu.itemList).thenReturn([catalog1, catalog2]);

    await tester.pumpWidget(MaterialApp(home: OrderScreen()));

    expect(find.text('pro-1'), findsOneWidget);

    await tester.tap(find.text('cat-2'));
    await tester.pump();

    expect(find.text('pro-1'), findsNothing);
    expect(find.text('pro-2'), findsOneWidget);
  });

  testWidgets('should scroll to bottom when select product', (tester) async {
    final product = ProductModel(index: 1, name: 'pro-1', id: 'pro-1');
    final catalog = CatalogModel(
      index: 1,
      name: 'cat-1',
      id: 'cat-1',
      products: {'pro-1': product},
    );
    when(menu.setUpStockMode(any)).thenReturn(true);
    when(menu.itemList).thenReturn([catalog]);

    await tester.pumpWidget(MaterialApp(home: OrderScreen()));

    await tester.tap(find.byType(OutlinedButton));
    await tester.tap(find.byType(OutlinedButton));
    await tester.tap(find.text('pro-1'));
    await tester.tap(find.text('pro-1'));
    await tester.tap(find.text('pro-1'));
    await tester.tap(find.text('pro-1'));
    await tester.tap(find.text('pro-1'));
    await tester.tap(find.text('pro-1'));
    await tester.pumpAndSettle();

    final widget = tester.firstWidget(find.byType(ListTile).last) as ListTile;
    final scroll = tester.firstWidget(find.byType(SingleChildScrollView))
        as SingleChildScrollView;

    expect(widget.selected, isTrue);
    expect(scroll.controller?.position.maxScrollExtent, isNonZero);
  });

  setUpAll(() {
    initialize();
    initializeProviders();
  });
}
