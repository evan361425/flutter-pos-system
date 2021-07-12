import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/components/dialog/delete_dialog.dart';
import 'package:possystem/components/style/search_bar_inline.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/menu/product_ingredient_model.dart';
import 'package:possystem/models/stock/ingredient_model.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/menu/product/widgets/product_ingredient_modal.dart';

import '../../../../mocks/mockito/mock_product_model.dart';
import '../../../../mocks/mocks.dart';
import '../../../../models/repository/stock_model_test.mocks.dart';

void main() {
  testWidgets('should update', (tester) async {
    final oldIngredient = IngredientModel(name: 'ing-1', id: 'ing-1');
    final newIngredient = IngredientModel(name: 'ing-2', id: 'ing-2');
    final product = MockProductModel();
    when(product.prefix).thenReturn('p-id');
    when(product.hasItem('ing-2')).thenReturn(false);
    when(product.setItem(any)).thenAnswer((_) => Future.value());
    when(product.toString()).thenReturn('product');
    when(stock.getItem('ing-2')).thenReturn(newIngredient);
    when(storage.set(any, any)).thenAnswer((_) => Future.value());
    final productIngredient = ProductIngredientModel(
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

    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    verify(product.removeItem('ing-1'));
    verify(storage.set(any, argThat(equals({'p-id.ingredients.ing-1': null}))));
    verify(product.setItem(argThat(predicate<ProductIngredientModel>((model) {
      return model.id == 'ing-2';
    }))));
  });

  testWidgets('should add new item', (tester) async {
    final product = MockProductModel();
    final ingredient = MockIngredientModel();
    when(product.prefix).thenReturn('p-id');
    when(product.hasItem('ing-1')).thenReturn(false);
    when(product.setItem(any)).thenAnswer((_) => Future.value());
    when(product.toString()).thenReturn('product');
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

    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    verify(product.setItem(argThat(predicate<ProductIngredientModel>((model) {
      return identical(model.product, product) &&
          model.amount == 1 &&
          identical(ingredient, model.ingredient);
    })))).called(1);
  });

  testWidgets('should pop delete warning', (tester) async {
    final ingredient = IngredientModel(name: 'ing-1', id: 'ing-1');
    final product = MockProductModel();
    final productIngredient = ProductIngredientModel(
      product: product,
      ingredient: ingredient,
    );
    LOG_LEVEL = 0;

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

    expect(find.byType(DeleteDialog), findsOneWidget);
  });

  setUpAll(() {
    initialize();
  });
}
