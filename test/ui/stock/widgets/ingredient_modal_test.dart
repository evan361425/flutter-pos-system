import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/ui/stock/widgets/ingredient_modal.dart';

import '../../../mocks/mock_models.mocks.dart';
import '../../../mocks/mock_storage.dart';
import '../../../mocks/mock_widgets.dart';
import '../../../mocks/mock_repos.dart';

void main() {
  testWidgets('should update', (tester) async {
    final ingredient = Ingredient(name: 'name', id: 'id');
    final catalog = MockCatalog();
    final product = MockProduct();
    final productIngredient = MockProductIngredient();
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
    await tester.tap(find.text('save'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).last, '30');
    await tester.tap(find.text('save'));

    verify(storage.set(
        any,
        argThat(predicate<Map<String, Object>>((map) =>
            map['id.name'] == 'name-new' &&
            map['id.currentAmount'] == 30 &&
            map['id.updatedAt'] != null)))).called(1);
    verify(stock.setItem(any));
  });
  testWidgets('should add new item', (tester) async {
    when(stock.setItem(any)).thenAnswer((_) => Future.value());
    when(stock.hasName(any)).thenReturn(false);

    await tester.pumpWidget(bindWithNavigator(IngredientModal()));

    await tester.enterText(find.byType(TextFormField).first, 'name');
    await tester.enterText(find.byType(TextFormField).last, '2');

    await tester.tap(find.text('save'));
    verify(stock.setItem(argThat(predicate<Ingredient>((object) {
      return object.name == 'name' && object.currentAmount == 2;
    })))).called(1);
  });

  setUpAll(() {
    initializeRepos();
    initializeStorage();
  });
}
