import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/ui/menu/product/widgets/product_ingredient_modal.dart';
import 'package:provider/provider.dart';

import '../../../../mocks/mock_storage.dart';

void main() {
  testWidgets('should update', (tester) async {
    final ingredient1 = Ingredient(id: 'i-1', name: 'i-1');
    final ingredient2 = Ingredient(id: 'i-2', name: 'i-2', currentAmount: 1);
    final ingredient3 = Ingredient(id: 'i-3', name: 'i-3');
    final stock = Stock();
    stock.replaceItems({
      'i-1': ingredient1,
      'i-2': ingredient2,
      'i-3': ingredient3,
    });

    final pIngredient1 = ProductIngredient(id: 'pi-1', ingredient: ingredient1);
    final pIngredient2 = ProductIngredient(id: 'pi-2', ingredient: ingredient2);
    final product = Product(id: 'p-1', ingredients: {
      'pi-1': pIngredient1,
      'pi-2': pIngredient2,
    });
    final catalog = Catalog(id: 'c-1', products: {'p-1': product});
    final menu = Menu();
    menu.replaceItems({'c-1': catalog});
    product.catalog = catalog;
    pIngredient1.product = product;
    pIngredient2.product = product;

    var notifiedCount = 0;
    menu.addListener(() => notifiedCount++);
    catalog.addListener(() => notifiedCount++);
    product.addListener(() => notifiedCount++);

    await tester.pumpWidget(ChangeNotifierProvider<Stock>.value(
      value: stock,
      builder: (_, __) => MaterialApp(
        home: ProductIngredientModal(
          ingredient: pIngredient1,
          product: product,
        ),
      ),
    ));

    // search for ingredient2
    await tester.tap(find.byKey(Key('menu.ingredient.search')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '2');
    await tester.pumpAndSettle();

    // go into modal and edit ingredient2 name
    await tester.tap(find.byIcon(Icons.open_in_new_sharp));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(Key('stock.ingredient.name')), 'i-2-n');
    await tester.pumpAndSettle();
    await tester.tap(find.text('save'));
    await tester.pumpAndSettle();

    // select new name
    await tester.tap(find.text('i-2-n'));
    await tester.pumpAndSettle();

    // enter amount
    await tester.enterText(find.byKey(Key('menu.ingredient.amount')), '1');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    // error message
    expect(find.text('name_repeat'), findsOneWidget);

    // search for ingredient3
    await tester.tap(find.byKey(Key('menu.ingredient.search')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'abc');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '3');
    await tester.pumpAndSettle();
    await tester.tap(find.text('i-3'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('save'));
    await tester.pumpAndSettle();

    // edit ingredient and product ingredient
    final captured = verify(storage.set(any, captureAny)).captured;
    expect(captured.length, equals(2));

    final prefix = pIngredient1.prefix;
    expect(captured[1], predicate<Map>((map) {
      return map['$prefix.amount'] == 1 && map['$prefix.ingredientId'] == 'i-3';
    }));
    expect(notifiedCount, greaterThanOrEqualTo(2));
  });

  testWidgets('should add new item', (tester) async {
    final stock = Stock();

    final product = Product(id: 'p-1');
    final catalog = Catalog(id: 'c-1', products: {'p-1': product});
    final menu = Menu();
    menu.replaceItems({'c-1': catalog});
    product.catalog = catalog;

    var notifiedCount = 0;
    menu.addListener(() => notifiedCount++);
    catalog.addListener(() => notifiedCount++);
    product.addListener(() => notifiedCount++);

    await tester.pumpWidget(ChangeNotifierProvider<Stock>.value(
      value: stock,
      builder: (_, __) => MaterialApp(
        home: ProductIngredientModal(product: product),
      ),
    ));

    // enter amount
    await tester.enterText(find.byKey(Key('menu.ingredient.amount')), '1');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    // error message
    expect(find.text('name_empty'), findsOneWidget);

    // add new ingredient
    await tester.tap(find.byKey(Key('menu.ingredient.search')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'new-ingredient');
    await tester.pumpAndSettle();
    await tester.tap(find.text('add_ingredient-new-ingredient'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('save'));
    await tester.pumpAndSettle();

    verify(storage.set(any, argThat(predicate<Map>((map) {
      final data = map.values.first as Map<String, Object>;
      return data['amount'] == 1;
    }))));
    expect(notifiedCount, greaterThanOrEqualTo(2));
  });

  setUpAll(() {
    initializeStorage();
  });
}
