import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/ui/menu/product/widgets/product_quantity_modal.dart';
import 'package:provider/provider.dart';

import '../../../../mocks/mock_storage.dart';

void main() {
  testWidgets('should update', (tester) async {
    final quantity1 = Quantity(id: 'q-1', name: 'q-1');
    final quantity2 = Quantity(id: 'q-2', name: 'q-2');
    final quantity3 = Quantity(id: 'q-3', name: 'q-3');
    final quantities = Quantities();
    quantities.replaceItems({
      'q-1': quantity1,
      'q-2': quantity2,
      'q-3': quantity3,
    });

    final pQuantity1 = ProductQuantity(id: 'pq-1', quantity: quantity1);
    final pQuantity2 = ProductQuantity(id: 'pq-2', quantity: quantity2);
    final ingredient = ProductIngredient(id: 'pi-1', quantities: {
      'pq-1': pQuantity1,
      'pq-2': pQuantity2,
    });
    final product = Product(id: 'p-1', ingredients: {'pi-1': ingredient});
    final catalog = Catalog(id: 'c-1', products: {'p-1': product});
    final menu = Menu();
    menu.replaceItems({'c-1': catalog});
    product.catalog = catalog;
    ingredient.product = product;
    pQuantity1.ingredient = ingredient;
    pQuantity2.ingredient = ingredient;

    var notifiedCount = 0;
    menu.addListener(() => notifiedCount++);
    catalog.addListener(() => notifiedCount++);
    product.addListener(() => notifiedCount++);

    await tester.pumpWidget(ChangeNotifierProvider<Quantities>.value(
      value: quantities,
      builder: (_, __) => MaterialApp(
        home: ProductQuantityModal(
          ingredient: ingredient,
          quantity: pQuantity1,
        ),
      ),
    ));

    // search for quantity2
    await tester.tap(find.byKey(Key('menu.quantity.search')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '2');
    await tester.pumpAndSettle();

    // go into modal and edit ingredient2 name
    await tester.tap(find.byIcon(Icons.open_in_new_sharp));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(Key('quantities.quantity.name')), 'q-2-n');
    await tester.pumpAndSettle();
    await tester.tap(find.text('save'));
    await tester.pumpAndSettle();

    // select new name
    await tester.tap(find.text('q-2-n'));
    await tester.pumpAndSettle();

    // edit properties
    await tester.enterText(find.byKey(Key('menu.quantity.price')), '1');
    await tester.enterText(find.byKey(Key('menu.quantity.cost')), '1');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    // error message
    expect(find.text('name_repeat'), findsOneWidget);

    // search for ingredient3
    await tester.tap(find.byKey(Key('menu.quantity.search')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'abc');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '3');
    await tester.pumpAndSettle();
    await tester.tap(find.text('q-3'));
    await tester.pumpAndSettle();

    // amount will be effect by proportion
    await tester.enterText(find.byKey(Key('menu.quantity.amount')), '1');
    await tester.tap(find.text('save'));
    await tester.pumpAndSettle();

    // edit ingredient and product ingredient
    final captured = verify(storage.set(any, captureAny)).captured;
    expect(captured.length, equals(2));

    final prefix = pQuantity1.prefix;
    expect(captured[1], predicate<Map>((map) {
      return map['$prefix.amount'] == 1 &&
          map['$prefix.additionalPrice'] == 1 &&
          map['$prefix.additionalCost'] == 1 &&
          map['$prefix.quantityId'] == 'q-3';
    }));
    expect(notifiedCount, greaterThanOrEqualTo(2));
  });

  testWidgets('should add new item', (tester) async {
    final quantities = Quantities();

    final ingredient = ProductIngredient(id: 'pi-1');
    final product = Product(id: 'p-1', ingredients: {'pi-1': ingredient});
    final catalog = Catalog(id: 'c-1', products: {'p-1': product});
    final menu = Menu();
    menu.replaceItems({'c-1': catalog});
    product.catalog = catalog;
    ingredient.product = product;

    var notifiedCount = 0;
    menu.addListener(() => notifiedCount++);
    catalog.addListener(() => notifiedCount++);
    product.addListener(() => notifiedCount++);

    await tester.pumpWidget(ChangeNotifierProvider<Quantities>.value(
      value: quantities,
      builder: (_, __) => MaterialApp(
        home: ProductQuantityModal(ingredient: ingredient),
      ),
    ));

    // enter amount
    await tester.enterText(find.byKey(Key('menu.quantity.amount')), '1');
    await tester.enterText(find.byKey(Key('menu.quantity.price')), '1');
    await tester.enterText(find.byKey(Key('menu.quantity.cost')), '1');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    // error message
    expect(find.text('name_empty'), findsOneWidget);

    // add new ingredient
    await tester.tap(find.byKey(Key('menu.quantity.search')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'new-quantity');
    await tester.pumpAndSettle();
    await tester.tap(find.text('add_quantity-new-quantity'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('save'));
    await tester.pumpAndSettle();

    verify(storage.set(any, argThat(predicate<Map>((map) {
      final data = map.values.first as Map<String, Object>;
      return data['amount'] == 0 &&
          data['additionalPrice'] == 1 &&
          data['additionalCost'] == 1;
    }))));
    expect(notifiedCount, greaterThanOrEqualTo(2));
  });

  setUpAll(() {
    initializeStorage();
  });
}
