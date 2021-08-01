import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/menu/product/product_screen.dart';
import 'package:provider/provider.dart';

import '../../../mocks/mock_models.mocks.dart';
import '../../../mocks/mock_repos.dart';

void main() {
  testWidgets('should show empty body if empty', (tester) async {
    final product = Product(index: 1, name: 'name');

    await tester.pumpWidget(MultiProvider(providers: [
      ChangeNotifierProvider<Product>.value(value: product),
    ], child: MaterialApp(home: ProductScreen())));

    expect(find.byType(EmptyBody), findsOneWidget);
  });

  testWidgets('should navigate to modal', (tester) async {
    final catalog = Catalog(index: 1, name: 'name');
    final product = Product(index: 1, name: 'name', catalog: catalog);
    var argument;

    await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<Product>.value(value: product),
        ],
        child: MaterialApp(
          routes: {
            Routes.menuProductModal: (context) {
              argument = ModalRoute.of(context)!.settings.arguments;
              return Container();
            },
          },
          home: ProductScreen(),
        )));

    // tap tile
    await tester.tap(find.byIcon(KIcons.edit));
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

    when(ingredient.items).thenReturn([]);
    when(ingredient.name).thenReturn('ing-name');
    when(ingredient.amount).thenReturn(1);

    var argument;

    await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<Product>.value(value: product),
        ],
        child: MaterialApp(
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
