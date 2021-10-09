import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/stock/replenishment.dart';
import 'package:possystem/ui/stock/replenishment/replenishment_modal.dart';

import '../../../mocks/mock_models.mocks.dart';
import '../../../mocks/mock_storage.dart';
import '../../../mocks/mock_widgets.dart';
import '../../../mocks/mock_repos.dart';

void main() {
  MockIngredient createIngredient(String id, String name) {
    final ingredient = MockIngredient();
    when(ingredient.id).thenReturn(id);
    when(ingredient.name).thenReturn(name);
    return ingredient;
  }

  testWidgets('should update', (tester) async {
    final replenishment = Replenishment(name: 'name', id: 'id', data: {
      'ing-1': 1,
      'ing-2': 2,
    });
    final ingredient1 = createIngredient('ing-1', 'ing-1-name');
    final ingredient2 = createIngredient('ing-2', 'ing-2-name');
    when(storage.set(any, any)).thenAnswer((_) => Future.value());
    when(stock.itemList).thenReturn([ingredient1, ingredient2]);
    when(stock.length).thenReturn(2);
    when(replenisher.hasName(any)).thenReturn(false);

    await tester.pumpWidget(
      bindWithNavigator(ReplenishmentModal(replenishment: replenishment)),
    );

    await tester.enterText(find.byType(TextFormField).first, 'name-new');
    await tester.enterText(find.byType(TextFormField).last, '3');
    await tester.tap(find.text('save'));

    verify(storage.set(
        any,
        argThat(equals({
          'id.name': 'name-new',
          'id.data.ing-2': 3,
        })))).called(1);
  });

  testWidgets('should add new item', (tester) async {
    final ingredient1 = createIngredient('ing-1', 'ing-1-name');
    final ingredient2 = createIngredient('ing-2', 'ing-2-name');
    when(stock.itemList).thenReturn([ingredient1, ingredient2]);
    when(stock.length).thenReturn(2);
    when(replenisher.hasName('name')).thenReturn(false);

    await tester.pumpWidget(bindWithNavigator(ReplenishmentModal()));

    await tester.enterText(find.byType(TextFormField).first, 'name');
    await tester.enterText(find.byType(TextFormField).at(1), '1');
    await tester.enterText(find.byType(TextFormField).last, '2');

    await tester.tap(find.text('save'));

    verify(replenisher.setItem(argThat(predicate<Replenishment>((model) {
      return model.name == 'name' &&
          mapEquals(model.data, {
            'ing-1': 1,
            'ing-2': 2,
          });
    })))).called(1);
  });

  setUpAll(() {
    initializeRepos();
    initializeStorage();
  });
}
