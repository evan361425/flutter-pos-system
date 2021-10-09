import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/components/dialog/delete_dialog.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/menu/product/widgets/product_ingredient_list.dart';

void main() {
  ProductIngredient createIngredient(String name, int amount,
      [Map<String, int>? quantityData]) {
    final quantities = <String, ProductQuantity>{};
    if (quantityData != null) {
      quantityData.forEach((key, value) {
        final quantity = Quantity(name: key, id: key);
        final productQuantity = ProductQuantity(
            amount: value,
            additionalCost: value,
            additionalPrice: value,
            quantity: quantity);
        quantities[key] = productQuantity;
      });
    }
    final ingredient = Ingredient(name: name, id: name);
    final productIngredient =
        ProductIngredient(ingredient: ingredient, quantities: quantities);
    quantities.values
        .forEach((quantity) => quantity.ingredient = productIngredient);

    return productIngredient;
  }

  testWidgets('should show delete confirm', (tester) async {
    final catalog = Catalog(index: 1, name: 'c-name');
    final ingredient = createIngredient('ing-1', 10, {'qua-1': 10});
    final product = Product(
      index: 1,
      name: 'name',
      ingredients: {'ing-1': ingredient},
      catalog: catalog,
    );
    ingredient.product = product;

    await tester.pumpWidget(MaterialApp(
      home: Material(child: IngredientExpansionTile(ingredient: ingredient)),
    ));

    // open panel
    await tester.longPress(find.text('ing-1'));
    await tester.pumpAndSettle();

    // tap tile
    await tester.tap(find.byIcon(KIcons.delete));
    await tester.pumpAndSettle();

    expect(find.byType(DeleteDialog), findsOneWidget);
  });

  testWidgets('should navigate to ingredient', (tester) async {
    final catalog = Catalog(index: 1, name: 'c-name');
    final ingredient = createIngredient('ing-1', 10, {'qua-1': 10});
    final product = Product(
      index: 1,
      name: 'name',
      ingredients: {'ing-1': ingredient},
      catalog: catalog,
    );
    product.items.forEach((ingredient) => ingredient.product = product);
    var argument;

    await tester.pumpWidget(MaterialApp(
      routes: {
        Routes.menuIngredient: (context) {
          argument = ModalRoute.of(context)!.settings.arguments;
          return Container();
        },
      },
      home: Material(child: IngredientExpansionTile(ingredient: ingredient)),
    ));

    // open panel
    await tester.tap(find.text('ing-1'));
    await tester.pumpAndSettle();

    // tap tile
    await tester.tap(find.byIcon(Icons.settings_sharp).first);
    await tester.pumpAndSettle();

    expect(identical(ingredient, argument), isTrue);
  });

  testWidgets('should navigate to edit quantity', (tester) async {
    final catalog = Catalog(index: 1, name: 'c-name');
    final ingredient = createIngredient('ing-1', 10, {'qua-1': 10});
    final product = Product(
      index: 1,
      name: 'name',
      ingredients: {'ing-1': ingredient},
      catalog: catalog,
    );
    product.items.forEach((ingredient) => ingredient.product = product);
    var argument;

    await tester.pumpWidget(MaterialApp(
      routes: {
        Routes.menuQuantity: (context) {
          argument = ModalRoute.of(context)!.settings.arguments;
          return Container();
        },
      },
      home: Material(child: IngredientExpansionTile(ingredient: ingredient)),
    ));

    // open panel
    await tester.tap(find.text('ing-1'));
    await tester.pumpAndSettle();

    // tap tile
    await tester.tap(find.text('qua-1'));
    await tester.pumpAndSettle();

    expect(identical(ingredient.items.first, argument), isTrue);
  });

  testWidgets('should navigate to add quantity', (tester) async {
    final catalog = Catalog(index: 1, name: 'c-name');
    final ingredient = createIngredient('ing-1', 10, {'qua-1': 10});
    final product = Product(
      index: 1,
      name: 'name',
      ingredients: {'ing-1': ingredient},
      catalog: catalog,
    );
    product.items.forEach((ingredient) => ingredient.product = product);
    var argument;

    await tester.pumpWidget(MaterialApp(
      routes: {
        Routes.menuQuantity: (context) {
          argument = ModalRoute.of(context)!.settings.arguments;
          return Container();
        },
      },
      home: Material(child: IngredientExpansionTile(ingredient: ingredient)),
    ));

    // open panel
    await tester.tap(find.text('ing-1'));
    await tester.pumpAndSettle();

    // tap tile
    await tester.tap(find.byIcon(KIcons.add).first);
    await tester.pumpAndSettle();

    expect(identical(ingredient, argument), isTrue);
  });
}
