import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/menu/catalog_model.dart';
import 'package:possystem/models/menu/product_ingredient_model.dart';
import 'package:possystem/models/menu/product_model.dart';
import 'package:possystem/models/menu/product_quantity_model.dart';
import 'package:possystem/models/stock/ingredient_model.dart';
import 'package:possystem/models/stock/quantity_model.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/menu/product/widgets/ingredient_expansion.dart';
import 'package:provider/provider.dart';

void main() {
  ProductIngredientModel createIngredient(String name, int amount,
      [Map<String, int>? quantityData]) {
    final quantities = <String, ProductQuantityModel>{};
    if (quantityData != null) {
      quantityData.forEach((key, value) {
        final quantity = QuantityModel(name: key, id: key);
        final productQuantity = ProductQuantityModel(
            amount: value,
            additionalCost: value,
            additionalPrice: value,
            quantity: quantity);
        quantities[key] = productQuantity;
      });
    }
    final ingredient = IngredientModel(name: name, id: name);
    final productIngredient =
        ProductIngredientModel(ingredient: ingredient, quantities: quantities);
    quantities.values
        .forEach((quantity) => quantity.ingredient = productIngredient);

    return productIngredient;
  }

  testWidgets('should navigate to ingredient', (tester) async {
    final catalog = CatalogModel(index: 1, name: 'c-name');
    final ingredient = createIngredient('ing-1', 10, {'qua-1': 10});
    final product = ProductModel(
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
      home: SingleChildScrollView(
        child: IngredientExpansion(ingredients: product.itemList),
      ),
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
    final catalog = CatalogModel(index: 1, name: 'c-name');
    final ingredient = createIngredient('ing-1', 10, {'qua-1': 10});
    final product = ProductModel(
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
      home: SingleChildScrollView(
        child: IngredientExpansion(ingredients: product.itemList),
      ),
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
    final catalog = CatalogModel(index: 1, name: 'c-name');
    final ingredient = createIngredient('ing-1', 10, {'qua-1': 10});
    final product = ProductModel(
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
      home: SingleChildScrollView(
        child: IngredientExpansion(ingredients: product.itemList),
      ),
    ));

    // open panel
    await tester.tap(find.text('ing-1'));
    await tester.pumpAndSettle();

    // tap tile
    await tester.tap(find.byIcon(KIcons.add).first);
    await tester.pumpAndSettle();

    expect(identical(ingredient, argument), isTrue);
  });

  testWidgets('show/hide correctly', (tester) async {
    final catalog = CatalogModel(index: 1, name: 'c-name');
    final ingredient1 = createIngredient('ing-1', 10, {'qua-1': 10});
    final ingredient2 = createIngredient('ing-2', 10, {'qua-2': 10});
    final product = ProductModel(
      index: 1,
      name: 'name',
      ingredients: {'ing-1': ingredient1, 'ing-2': ingredient2},
      catalog: catalog,
    );
    final expansion = Key('expansion');
    product.items.forEach((ingredient) => ingredient.product = product);

    bool needPaint(String text) {
      return find.text(text).evaluate().first.renderObject!.debugNeedsPaint;
    }

    await tester.pumpWidget(MaterialApp(
      home: SingleChildScrollView(
        child: IngredientExpansion(
          key: expansion,
          ingredients: product.itemList,
        ),
      ),
    ));

    expect(needPaint('qua-1'), isTrue);
    expect(needPaint('qua-2'), isTrue);

    // open first panel
    await tester.tap(find.text('ing-1'));
    await tester.pumpAndSettle();

    expect(needPaint('qua-1'), isFalse);
    expect(needPaint('qua-2'), isTrue);

    // open second panel
    await tester.tap(find.text('ing-2'));
    await tester.pumpAndSettle();

    expect(needPaint('qua-1'), isFalse);
    expect(needPaint('qua-2'), isFalse);

    final oldHeight = find.byKey(expansion).evaluate().first.size!.height;

    // close first panel
    await tester.tap(find.text('ing-1'));
    await tester.pumpAndSettle();

    final newHeight = find.byKey(expansion).evaluate().first.size!.height;
    expect(oldHeight, greaterThan(newHeight));
  });

  testWidgets('when product changed should keep open', (tester) async {
    final catalog = CatalogModel(index: 1, name: 'c-name');
    final ingredient1 = createIngredient('ing-1', 10, {'qua-1': 10});
    final ingredient2 = createIngredient('ing-2', 10, {'qua-2': 10});
    final product = ProductModel(
      index: 1,
      name: 'name',
      ingredients: {'ing-1': ingredient1, 'ing-2': ingredient2},
      catalog: catalog,
    );
    final expansion = Key('expansion');
    product.items.forEach((ingredient) => ingredient.product = product);
    bool needPaint(String text) {
      final obj = find.text(text).evaluate().first.renderObject!;
      return obj.debugNeedsPaint;
    }

    await tester.pumpWidget(MultiProvider(
      providers: [ChangeNotifierProvider.value(value: product)],
      builder: (context, _) {
        final p = context.watch<ProductModel>();
        return MaterialApp(
          home: SingleChildScrollView(
            child: IngredientExpansion(
              key: expansion,
              ingredients: p.itemList,
            ),
          ),
        );
      },
    ));

    // open first panel
    await tester.tap(find.text('ing-1'));
    await tester.pumpAndSettle();

    // open second panel
    await tester.tap(find.text('ing-2'));
    await tester.pumpAndSettle();

    expect(needPaint('qua-1'), isFalse);
    expect(needPaint('qua-2'), isFalse);

    final oldHeight = find.byKey(expansion).evaluate().first.size!.height;

    // notify change
    product.getItem('ing-1')!.getItem('qua-1')!.quantity.name = 'qua-new';
    product.notifyItem();
    await tester.pumpAndSettle();

    final newHeight = find.byKey(expansion).evaluate().first.size!.height;
    expect(find.text('qua-new'), findsOneWidget);
    expect(oldHeight, equals(newHeight));
  });
}
