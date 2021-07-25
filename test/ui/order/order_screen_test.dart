import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/ui/order/cashier/calculator_dialog.dart';
import 'package:possystem/ui/order/order_screen.dart';
import 'package:provider/provider.dart';

import '../../mocks/mock_repos.dart';
import '../../mocks/mock_providers.dart';

void main() {
  testWidgets('should show actions', (tester) async {
    when(menu.setUpStockMode(any)).thenReturn(false);

    await tester.pumpWidget(MaterialApp(
      home: ChangeNotifierProvider<Menu>.value(
        value: menu,
        child: OrderScreen(),
      ),
    ));

    await tester.tap(find.byIcon(KIcons.more));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.cancel_sharp), findsOneWidget);
  });

  testWidgets('should show dialog when order', (tester) async {
    when(menu.setUpStockMode(any)).thenReturn(false);
    when(currency.isInt).thenReturn(true);

    await tester.pumpWidget(MaterialApp(
      home: ChangeNotifierProvider<Menu>.value(
        value: menu,
        child: OrderScreen(),
      ),
    ));

    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    expect(find.byType(CalculatorDialog), findsOneWidget);
  });

  testWidgets('should build success in landscape mode', (tester) async {
    when(menu.setUpStockMode(any)).thenReturn(true);
    when(menu.itemList).thenReturn([]);

    const WIDTH = 1800.0;
    const HEIGHT = 1000.0;

    tester.binding.window.physicalSizeTestValue = Size(WIDTH, HEIGHT);

    // resets the screen to its orinal size after the test end
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

    await tester.pumpWidget(MaterialApp(
      home: ChangeNotifierProvider<Menu>.value(
        value: menu,
        child: OrderScreen(),
      ),
    ));
  });

  testWidgets('should update products when select catalog', (tester) async {
    final ingredient = Ingredient(name: 'ing-1', id: 'ing-1');
    final quantity = Quantity(name: 'qua-1', id: 'qua-1');
    final proQuantity = ProductQuantity(quantity: quantity);
    final proIngredient = ProductIngredient(
      ingredient: ingredient,
      quantities: {'qua-1': proQuantity},
    );
    final product1 = Product(
      index: 1,
      name: 'pro-1',
      id: 'pro-1',
      ingredients: {'ing-1': proIngredient},
    );
    final product2 = Product(index: 1, name: 'pro-2', id: 'pro-2');
    final catalog1 = Catalog(
      index: 1,
      name: 'cat-1',
      id: 'cat-1',
      products: {'pro-1': product1},
    );
    final catalog2 = Catalog(
      index: 1,
      name: 'cat-2',
      id: 'cat-2',
      products: {'pro-2': product2},
    );
    when(menu.setUpStockMode(any)).thenReturn(true);
    when(menu.itemList).thenReturn([catalog1, catalog2]);

    await tester.pumpWidget(MaterialApp(
      home: ChangeNotifierProvider<Menu>.value(
        value: menu,
        child: OrderScreen(),
      ),
    ));

    expect(find.text('pro-1'), findsOneWidget);

    await tester.tap(find.text('cat-2'));
    await tester.pump();

    expect(find.text('pro-1'), findsNothing);
    expect(find.text('pro-2'), findsOneWidget);
  });

  testWidgets('should scroll to bottom when select product', (tester) async {
    final product = Product(index: 1, name: 'pro-1', id: 'pro-1');
    final catalog = Catalog(
      index: 1,
      name: 'cat-1',
      id: 'cat-1',
      products: {'pro-1': product},
    );
    when(menu.setUpStockMode(any)).thenReturn(true);
    when(menu.itemList).thenReturn([catalog]);

    await tester.pumpWidget(MaterialApp(
      home: ChangeNotifierProvider<Menu>.value(
        value: menu,
        child: OrderScreen(),
      ),
    ));

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
    initializeRepos();
    initializeProviders();
    Cart.instance = Cart();
  });

  tearDownAll(() {
    Cart.instance = cart;
  });
}
