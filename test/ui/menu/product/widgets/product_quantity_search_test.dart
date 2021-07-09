import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/components/style/card_tile.dart';
import 'package:possystem/models/stock/quantity_model.dart';
import 'package:possystem/ui/menu/product/widgets/product_quantity_search.dart';

import '../../../../mocks/mock_widgets.dart';
import '../../../../mocks/mocks.dart';

void main() {
  testWidgets('should add new item', (tester) async {
    when(quantities.itemList).thenReturn([]);
    when(quantities.sortBySimilarity(any)).thenReturn([]);
    when(quantities.setItem(any)).thenAnswer((_) => Future.value());

    await tester.pumpWidget(bindWithNavigator(ProductQuantitySearch()));

    await tester.enterText(find.byType(TextField), 'some-qua');
    await tester.pumpAndSettle();

    await tester.tap(find.byType(CardTile));
    await tester.pumpAndSettle();

    verify(quantities.setItem(argThat(predicate<QuantityModel>((model) {
      return model.name == 'some-qua';
    }))));
  });

  setUpAll(() {
    initialize();
  });
}
