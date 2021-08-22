import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/components/style/card_tile.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/ui/menu/product/widgets/product_ingredient_search.dart';
import 'package:provider/provider.dart';

import '../../../../mocks/mock_widgets.dart';
import '../../../../mocks/mock_repos.dart';

void main() {
  Widget bindWithProvider(Widget widget) {
    return ChangeNotifierProvider<Stock>.value(
      value: stock,
      child: widget,
    );
  }

  testWidgets('should add new item', (tester) async {
    when(stock.itemList).thenReturn([]);
    when(stock.sortBySimilarity(any)).thenReturn([]);
    when(stock.setItem(any)).thenAnswer((_) => Future.value());

    await tester.pumpWidget(bindWithProvider(bindWithNavigator(
      ProductIngredientSearch(),
    )));

    await tester.enterText(find.byType(TextField), 'some-ing');
    await tester.pumpAndSettle();

    await tester.tap(find.byType(CardTile));
    await tester.pumpAndSettle();

    verify(stock.setItem(argThat(predicate<Ingredient>((model) {
      return model.name == 'some-ing';
    }))));
  });

  testWidgets('should selectable', (tester) async {
    final ingredient = Ingredient(name: 'name', id: 'id');
    when(stock.itemList).thenReturn([ingredient]);
    when(menu.getIngredients('id')).thenReturn([]);

    Ingredient? argument;

    await tester.pumpWidget(bindWithProvider(MaterialApp(
      home: Navigator(
        onPopPage: (route, result) {
          argument = result;
          return route.didPop(result);
        },
        pages: [
          MaterialPage(child: Container()),
          MaterialPage(child: ProductIngredientSearch()),
        ],
      ),
    )));

    await tester.tap(find.byIcon(Icons.open_in_new_sharp));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(KIcons.back));
    await tester.pumpAndSettle();

    await tester.tap(find.text('name').first);
    await tester.pumpAndSettle();

    expect(identical(argument, ingredient), isTrue);
  });

  setUpAll(() {
    initializeRepos();
  });
}
