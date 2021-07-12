import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/components/style/circular_loading.dart';
import 'package:possystem/models/stock/ingredient_model.dart';
import 'package:possystem/ui/stock/widgets/ingredient_modal.dart';

import '../../../mocks/mock_widgets.dart';
import '../../../mocks/mockito/mock_catalog_model.dart';
import '../../../mocks/mockito/mock_product_ingredient_model.dart';
import '../../../mocks/mockito/mock_product_model.dart';
import '../../../mocks/mocks.dart';
import '../../../models/repository/stock_model_test.mocks.dart';

void main() {
  testWidgets('should update', (tester) async {
    final ingredient = IngredientModel(name: 'name', id: 'id');
    final catalog = MockCatalogModel();
    final product = MockProductModel();
    final productIngredient = MockProductIngredientModel();
    when(menu.setUpStockMode(any)).thenReturn(true);
    when(menu.getIngredients(any)).thenReturn([productIngredient]);
    when(productIngredient.product).thenReturn(product);
    when(product.catalog).thenReturn(catalog);
    when(product.name).thenReturn('p-name');
    when(catalog.name).thenReturn('c-name');
    when(stock.setItem(any)).thenAnswer((_) => Future.value());
    when(stock.hasName('name-new')).thenReturn(false);

    await tester.pumpWidget(bindWithNavigator(IngredientModal(
      ingredient: ingredient,
    )));

    await tester.enterText(find.byType(TextFormField).first, 'name-new');

    // should not do anything if not setting currentStock
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).last, '30');
    await tester.tap(find.byType(TextButton));

    verify(storage.set(
        any,
        argThat(predicate<Map<String, Object>>((map) =>
            map['id.name'] == 'name-new' &&
            map['id.currentAmount'] == 30 &&
            map['id.updatedAt'] != null)))).called(1);
    verify(stock.setItem(any));
  });

  testWidgets('should loading if stock mode not ready', (tester) async {
    final ingredient = MockIngredientModel();
    when(menu.setUpStockMode(any)).thenReturn(false);
    when(ingredient.name).thenReturn('name');
    when(ingredient.id).thenReturn('id');
    when(ingredient.currentAmount).thenReturn(1);

    await tester.pumpWidget(bindWithNavigator(IngredientModal(
      ingredient: ingredient,
    )));

    expect(find.byType(CircularLoading), findsOneWidget);
  });

  testWidgets('should add new item', (tester) async {
    when(menu.setUpStockMode(any)).thenReturn(true);
    when(stock.setItem(any)).thenAnswer((_) => Future.value());
    when(stock.hasName(any)).thenReturn(false);

    await tester.pumpWidget(bindWithNavigator(IngredientModal()));

    await tester.enterText(find.byType(TextFormField).first, 'name');
    await tester.enterText(find.byType(TextFormField).last, '2');

    await tester.tap(find.byType(TextButton));
    verify(stock.setItem(argThat(predicate<IngredientModel>((object) {
      return object.name == 'name' && object.currentAmount == 2;
    })))).called(1);
  });

  setUpAll(() {
    initialize();
  });
}
