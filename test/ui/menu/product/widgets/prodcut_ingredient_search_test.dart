import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/components/style/card_tile.dart';
import 'package:possystem/models/stock/ingredient_model.dart';
import 'package:possystem/ui/menu/product/widgets/product_ingredient_search.dart';

import '../../../../mocks/mock_widgets.dart';
import '../../../../mocks/mocks.dart';

void main() {
  testWidgets('should add new item', (tester) async {
    when(stock.itemList).thenReturn([]);
    when(stock.sortBySimilarity(any)).thenReturn([]);
    when(stock.setItem(any)).thenAnswer((_) => Future.value());

    await tester.pumpWidget(bindWithNavigator(ProductIngredientSearch()));

    await tester.enterText(find.byType(TextField), 'some-ing');
    await tester.pumpAndSettle();

    await tester.tap(find.byType(CardTile));
    await tester.pumpAndSettle();

    verify(stock.setItem(argThat(predicate<IngredientModel>((model) {
      return model.name == 'some-ing';
    }))));
  });

  setUpAll(() {
    initialize();
  });
}
