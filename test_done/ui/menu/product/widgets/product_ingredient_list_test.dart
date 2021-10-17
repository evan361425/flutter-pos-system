import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/menu/product/widgets/product_ingredient_list.dart';

import '../../../../mocks/mock_storage.dart';

void main() {
  testWidgets('should delete ingredient', (tester) async {
    var notifiedCount = 0;
    final menu = Menu();
    final catalog = Catalog();
    final product = Product(id: 'p-1', catalog: catalog);
    final ingredient = ProductIngredient(
        id: 'i-1', ingredient: Ingredient(), product: product);
    product.replaceItems({'i-1': ingredient});
    catalog.replaceItems({'p-1': product});
    product.addListener(() => notifiedCount++);
    catalog.addListener(() => notifiedCount++);
    menu.addListener(() => notifiedCount++);

    await tester.pumpWidget(MaterialApp(
      home: Material(child: ProductIngredientList([ingredient])),
    ));

    // open actions
    await tester.tap(find.text('ingredient'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(KIcons.more));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(KIcons.delete));
    await tester.pumpAndSettle();

    // confirm
    await tester.tap(find.text('delete'));
    await tester.pumpAndSettle();

    verify(storage.set(any, any));
    // notify menu is optional
    expect(notifiedCount, greaterThanOrEqualTo(2));
    expect(product.length, isZero);
  });

  testWidgets('should navigate correctly', (tester) async {
    final product = Product();
    final quantity = ProductQuantity(quantity: Quantity());
    final ingredient = ProductIngredient(ingredient: Ingredient(), quantities: {
      'id': quantity,
    });
    final poper = (BuildContext context) {
      final setting = ModalRoute.of(context)!.settings;
      return TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text('${setting.name}-${setting.arguments}'),
      );
    };
    product.replaceItems({'id': ingredient});

    await tester.pumpWidget(MaterialApp(routes: {
      Routes.menuQuantity: poper,
      Routes.menuIngredient: poper,
    }, home: ProductIngredientList([ingredient])));

    // open panel
    await tester.longPress(find.text('ingredient'));
    await tester.pumpAndSettle();

    // add quantity
    await tester.tap(find.byIcon(KIcons.add));
    await tester.pumpAndSettle();

    // pop
    await tester.tap(find.text('${Routes.menuQuantity}-ingredient'));
    await tester.pumpAndSettle();

    // show action
    await tester.tap(find.byIcon(KIcons.more));
    await tester.pumpAndSettle();

    // edit ingredient
    await tester.tap(find.byIcon(Icons.text_fields_sharp));
    await tester.pumpAndSettle();

    // pop
    await tester.tap(find.text('${Routes.menuIngredient}-ingredient'));
    await tester.pumpAndSettle();

    // quantity modal
    await tester.tap(find.text('quantity'));
    await tester.pumpAndSettle();

    // pop
    await tester.tap(find.text('${Routes.menuQuantity}-quantity'));
    await tester.pumpAndSettle();

    expect(find.byIcon(KIcons.add), findsOneWidget);
  });

  testWidgets('should delete quantity', (tester) async {
    var notifiedCount = 0;
    final menu = Menu();
    final catalog = Catalog();
    final product = Product(id: 'p-1', catalog: catalog);
    final ingredient = ProductIngredient(
        id: 'i-1', ingredient: Ingredient(), product: product);
    final quantity = ProductQuantity(
        id: 'q-1', quantity: Quantity(), ingredient: ingredient);
    ingredient.replaceItems({'q-1': quantity});
    product.replaceItems({'i-1': ingredient});
    catalog.replaceItems({'p-1': product});
    product.addListener(() => notifiedCount++);
    catalog.addListener(() => notifiedCount++);
    menu.addListener(() => notifiedCount++);

    await tester.pumpWidget(MaterialApp(
      home: Material(child: ProductIngredientList([ingredient])),
    ));

    // open panel
    await tester.tap(find.text('ingredient'));
    await tester.pumpAndSettle();

    // show actions
    await tester.longPress(find.text('quantity'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(KIcons.delete));
    await tester.pumpAndSettle();

    await tester.tap(find.text('delete'));
    await tester.pumpAndSettle();

    verify(storage.set(any, any));
    // notify menu/catalog is optional
    expect(notifiedCount, greaterThanOrEqualTo(1));
    expect(ingredient.length, isZero);
  });

  setUpAll(() {
    initializeStorage();
  });
}
