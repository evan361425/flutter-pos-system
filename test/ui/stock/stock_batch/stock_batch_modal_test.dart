import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/stock/stock_batch_model.dart';
import 'package:possystem/ui/stock/stock_batch/stock_batch_modal.dart';

import '../../../mocks/mock_widgets.dart';
import '../../../mocks/mocks.dart';
import '../../../models/repository/stock_model_test.mocks.dart';

void main() {
  MockIngredientModel createIngredient(String id, String name) {
    final ingredient = MockIngredientModel();
    when(ingredient.id).thenReturn(id);
    when(ingredient.name).thenReturn(name);
    return ingredient;
  }

  testWidgets('should update', (tester) async {
    final batch = StockBatchModel(name: 'name', id: 'id', data: {
      'ing-1': 1,
      'ing-2': 2,
    });
    final ingredient1 = createIngredient('ing-1', 'ing-1-name');
    final ingredient2 = createIngredient('ing-2', 'ing-2-name');
    when(storage.set(any, any)).thenAnswer((_) => Future.value());
    when(stock.itemList).thenReturn([ingredient1, ingredient2]);
    when(stock.length).thenReturn(2);
    when(batches.hasBatch(any)).thenReturn(false);

    await tester.pumpWidget(bindWithNavigator(StockBatchModal(batch: batch)));

    await tester.enterText(find.byType(TextFormField).first, 'name-new');
    await tester.enterText(find.byType(TextFormField).last, '3');
    await tester.tap(find.byType(TextButton));

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
    when(batches.hasBatch('name')).thenReturn(false);

    await tester.pumpWidget(bindWithNavigator(StockBatchModal()));

    await tester.enterText(find.byType(TextFormField).first, 'name');
    await tester.enterText(find.byType(TextFormField).at(1), '1');
    await tester.enterText(find.byType(TextFormField).last, '2');

    await tester.tap(find.byType(TextButton));

    verify(batches.setItem(argThat(predicate<StockBatchModel>((model) {
      return model.name == 'name' &&
          mapEquals(model.data, {
            'ing-1': 1,
            'ing-2': 2,
          });
    })))).called(1);
  });

  setUpAll(() {
    initialize();
  });
}
