import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/menu/product/product_screen.dart';
import 'package:provider/provider.dart';

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
    final product = Product();

    await tester.pumpWidget(bindWithProvider(
      product,
      MaterialApp(home: ProductScreen()),
    ));

    expect(find.byType(EmptyBody), findsOneWidget);
  });

  testWidgets('should navigate correctly', (tester) async {
    final product = Product(ingredients: {
      'i-1': ProductIngredient(id: 'i-1', ingredient: Ingredient()),
    });
    var navCount = 0;
    final poper = (BuildContext context) => TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text((++navCount).toString()),
        );

    await tester.pumpWidget(bindWithProvider(
        product,
        MaterialApp(routes: {
          Routes.menuProductModal: poper,
        }, home: ProductScreen())));

    await tester.tap(find.byIcon(KIcons.more));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.text_fields_sharp));
    await tester.pumpAndSettle();

    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('should addable', (tester) async {
    final product = Product();
    await tester.pumpWidget(bindWithProvider(
        product,
        MaterialApp(
          routes: {Routes.menuIngredient: (_) => Text('hi')},
          home: ProductScreen(),
        )));

    // tap to add ingredient
    await tester.tap(find.byIcon(KIcons.add));
    await tester.pumpAndSettle();

    expect(find.text('hi'), findsOneWidget);
  });
}
