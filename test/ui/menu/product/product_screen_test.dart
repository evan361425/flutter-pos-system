import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/menu/product/product_screen.dart';
import 'package:provider/provider.dart';

import '../../../mocks/mock_models.mocks.dart';
import '../../../mocks/mock_repos.dart';

void main() {
  Widget bindWithProvider(Product product, Widget child) {
    return MultiProvider(providers: [
      ChangeNotifierProvider<Product>.value(value: product),
      ChangeNotifierProvider<Stock>.value(value: stock),
      ChangeNotifierProvider<Quantities>.value(value: quantities),
    ], child: child);
  }

  testWidgets('should show empty body if empty', (tester) async {
    final product = Product(index: 1, name: 'name');

    await tester.pumpWidget(bindWithProvider(
      product,
      MaterialApp(home: ProductScreen()),
    ));

    expect(find.byType(EmptyBody), findsOneWidget);
  });

  testWidgets('should navigate to modal', (tester) async {
    final catalog = Catalog(index: 1, name: 'name');
    final product = Product(index: 1, name: 'name', catalog: catalog);
    var argument;

    await tester.pumpWidget(bindWithProvider(
        product,
        MaterialApp(
          routes: {
            Routes.menuProductModal: (context) {
              argument = ModalRoute.of(context)!.settings.arguments;
              return Container();
            },
          },
          home: ProductScreen(),
        )));

    // show actions
    await tester.tap(find.byIcon(KIcons.edit));
    await tester.pumpAndSettle();
    // go edit
    await tester.tap(find.byIcon(Icons.text_fields_sharp));
    await tester.pumpAndSettle();

    expect(identical(product, argument), isTrue);
  });

  testWidgets('should addable', (tester) async {
    final ingredient = MockProductIngredient();
    final catalog = Catalog(index: 1, name: 'name');
    final product = Product(
      index: 1,
      name: 'name',
      id: 'id',
      catalog: catalog,
      ingredients: {'ing-1': ingredient},
    );

    when(ingredient.isNotEmpty).thenReturn(false);
    when(ingredient.items).thenReturn([]);
    when(ingredient.name).thenReturn('ing-name');
    when(ingredient.amount).thenReturn(1);

    var argument;

    await tester.pumpWidget(bindWithProvider(
        product,
        MaterialApp(
          routes: {
            Routes.menuIngredient: (context) {
              argument = ModalRoute.of(context)!.settings.arguments;
              return Container();
            },
          },
          home: ProductScreen(),
        )));

    // tap to add ingredient
    await tester.tap(find.byIcon(KIcons.add).last);
    await tester.pumpAndSettle();

    expect(identical(argument, product), isTrue);
  });

  setUpAll(() {
    initializeRepos();
  });
}
