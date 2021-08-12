import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/components/style/search_bar_inline.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/menu/product/widgets/product_ingredient_modal.dart';

import '../../../../mocks/mock_models.mocks.dart';
import '../../../../mocks/mock_repos.dart';
import '../../../../mocks/mock_storage.dart';

void main() {
  testWidgets('should update', (tester) async {
    final oldIngredient = Ingredient(name: 'ing-1', id: 'ing-1');
    final newIngredient = Ingredient(name: 'ing-2', id: 'ing-2');
    final product = MockProduct();
    when(product.prefix).thenReturn('p-id');
    when(product.hasItem('ing-2')).thenReturn(false);
    when(product.setItem(any)).thenAnswer((_) => Future.value());
    when(stock.getItem('ing-2')).thenReturn(newIngredient);
    when(storage.set(any, any)).thenAnswer((_) => Future.value());
    final productIngredient = ProductIngredient(
      product: product,
      ingredient: oldIngredient,
    );
    LOG_LEVEL = 0;

    await tester.pumpWidget(MaterialApp(
      routes: {
        Routes.menuIngredientSearch: (_) {
          return FutureBuilder<bool>(
            future: Future.delayed(Duration(milliseconds: 10), () => true),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Navigator.of(context).pop(newIngredient);
              }
              return Container();
            },
          );
        }
      },
      home: ProductIngredientModal(
        ingredient: productIngredient,
        product: product,
      ),
    ));

    await tester.enterText(find.byType(TextFormField).first, '1');

    // search ingredient
    await tester.tap(find.byType(SearchBarInline));
    await tester.pumpAndSettle();
    await tester.pump(Duration(milliseconds: 15));

    await tester.tap(find.text('save'));
    await tester.pumpAndSettle();

    verify(product.removeItem('ing-1'));
    verify(storage.set(any, argThat(equals({'p-id.ingredients.ing-1': null}))));
    verify(product.setItem(argThat(predicate<ProductIngredient>((model) {
      return model.id == 'ing-2';
    }))));
  });

  testWidgets('should add new item', (tester) async {
    final product = MockProduct();
    final ingredient = MockIngredient();
    when(product.prefix).thenReturn('p-id');
    when(product.hasItem('ing-1')).thenReturn(false);
    when(product.setItem(any)).thenAnswer((_) => Future.value());
    when(stock.getItem('ing-1')).thenReturn(ingredient);
    when(ingredient.name).thenReturn('ing-name');
    when(ingredient.id).thenReturn('ing-1');

    await tester.pumpWidget(MaterialApp(
      routes: {
        Routes.menuIngredientSearch: (_) {
          return FutureBuilder<bool>(
            future: Future.delayed(Duration(milliseconds: 10), () => true),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Navigator.of(context).pop(ingredient);
              }
              return Container();
            },
          );
        }
      },
      home: ProductIngredientModal(
        product: product,
      ),
    ));

    await tester.enterText(find.byType(TextFormField).first, '1');

    // search ingredient
    await tester.tap(find.byType(SearchBarInline));
    await tester.pumpAndSettle();
    await tester.pump(Duration(milliseconds: 15));

    await tester.tap(find.text('save'));
    await tester.pumpAndSettle();

    verify(product.setItem(argThat(predicate<ProductIngredient>((model) {
      return identical(model.product, product) &&
          model.amount == 1 &&
          identical(ingredient, model.ingredient);
    })))).called(1);
  });

  testWidgets('should pop delete warning', (tester) async {
    final ingredient = Ingredient(name: 'ing-1', id: 'ing-1');
    final product = MockProduct();
    final productIngredient = ProductIngredient(
      product: product,
      ingredient: ingredient,
    );
    LOG_LEVEL = 0;
    when(storage.set(any, any)).thenAnswer((_) => Future.value());
    when(product.prefix).thenReturn('prefix');

    await tester.pumpWidget(MaterialApp(
      home: ProductIngredientModal(
        ingredient: productIngredient,
        product: product,
      ),
    ));

    // more
    await tester.tap(find.byIcon(KIcons.more));
    await tester.pumpAndSettle();

    // delete
    await tester.tap(find.byIcon(KIcons.delete));
    await tester.pumpAndSettle();
    await tester.tap(find.text('delete'));
    await tester.pumpAndSettle();

    verify(storage.set(any, any));
  });

  setUpAll(() {
    initializeRepos();
    initializeStorage();
  });
}
