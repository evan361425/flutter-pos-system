import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/components/style/card_tile.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/ui/menu/product/widgets/product_quantity_search.dart';
import 'package:provider/provider.dart';

import '../../../../mocks/mock_widgets.dart';
import '../../../../mocks/mock_repos.dart';

void main() {
  Widget bindWithProvider(Widget widget) {
    return ChangeNotifierProvider<Quantities>.value(
      value: quantities,
      child: widget,
    );
  }

  testWidgets('should add new item', (tester) async {
    when(quantities.itemList).thenReturn([]);
    when(quantities.sortBySimilarity(any)).thenReturn([]);
    when(quantities.setItem(any)).thenAnswer((_) => Future.value());

    await tester.pumpWidget(
      bindWithProvider(bindWithNavigator(ProductQuantitySearch())),
    );

    await tester.enterText(find.byType(TextField), 'some-qua');
    await tester.pumpAndSettle();

    await tester.tap(find.byType(CardTile));
    await tester.pumpAndSettle();

    verify(quantities.setItem(argThat(predicate<Quantity>((model) {
      return model.name == 'some-qua';
    }))));
  });

  testWidgets('should selectable', (tester) async {
    final quantity = Quantity(name: 'name', id: 'id');
    when(quantities.itemList).thenReturn([quantity]);

    Quantity? argument;

    await tester.pumpWidget(bindWithProvider(MaterialApp(
      home: Navigator(
        onPopPage: (route, result) {
          argument = result;
          return route.didPop(result);
        },
        pages: [
          MaterialPage(child: Container()),
          MaterialPage(child: ProductQuantitySearch()),
        ],
      ),
    )));

    await tester.tap(find.byIcon(Icons.open_in_new_sharp));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(KIcons.back));
    await tester.pumpAndSettle();

    await tester.tap(find.text('name').first);
    await tester.pumpAndSettle();

    expect(identical(argument, quantity), isTrue);
  });

  setUpAll(() {
    initializeRepos();
  });
}
