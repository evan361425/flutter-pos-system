import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/menu/menu_search.dart';

import '../../mocks/mock_storage.dart';

void main() {
  testWidgets('should update products when typing', (tester) async {
    final ingredient1 = ProductIngredient(
      id: 'pi-1',
      ingredient: Ingredient(id: 'i-1', name: 'i-1'),
    );
    final ingredient2 = ProductIngredient(
      id: 'pi-2',
      ingredient: Ingredient(id: 'i-2', name: 'i-2'),
    );
    final quantity = ProductQuantity(
      id: 'pq-1',
      ingredient: ingredient1,
      quantity: Quantity(id: 'q-1', name: 'q-1'),
    );
    final catalog = Catalog(id: 'c-1', products: {
      'p-1': Product(id: 'p-1', name: 'p-1', ingredients: {
        'pi-1': ingredient1,
        'pi-2': ingredient2,
      }),
      'p-2': Product(id: 'p-2', name: 'p-2'),
    });
    final menu = Menu();
    ingredient1.replaceItems({'pq-1': quantity});
    catalog.items.forEach((e) => e.catalog = catalog);
    menu.replaceItems({'c-1': catalog});

    await tester.pumpWidget(MaterialApp(
      routes: {
        Routes.menuProduct: (context) {
          final arg = ModalRoute.of(context)!.settings.arguments;
          return Text('navigated-$arg');
        }
      },
      home: MenuSearch(),
    ));

    expect(find.text('p-1'), findsOneWidget);
    expect(find.text('p-2'), findsOneWidget);

    // enter non-matched products
    await tester.enterText(find.byType(TextField), 'empty');
    await tester.pump();

    expect(find.text('搜尋不到相關資訊，打錯字了嗎？'), findsOneWidget);

    // enter match products (including ingredient)
    await tester.enterText(find.byType(TextField), '2');
    await tester.pump();

    expect(find.text('p-1'), findsOneWidget);
    expect(find.text('p-2'), findsOneWidget);

    // should match specific quantity
    await tester.enterText(find.byType(TextField), 'q-1');
    await tester.pump();

    expect(find.text('p-1'), findsOneWidget);
    expect(find.text('p-2'), findsNothing);

    // navigate to product
    await tester.tap(find.text('p-1'));
    await tester.pumpAndSettle();

    expect(find.text('navigated-p-1'), findsOneWidget);

    // should update searchedAt
    verify(storage.set(
      any,
      argThat(predicate<Map>((data) => data.values.first > 0)),
    ));
  });

  setUpAll(() {
    initializeStorage();
  });
}
