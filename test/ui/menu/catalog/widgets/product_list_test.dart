import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/models/menu/catalog_model.dart';
import 'package:possystem/models/menu/product_model.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/menu/catalog/widgets/product_list.dart';

void main() {
  testWidgets('should navigate to prodcut', (tester) async {
    final catalog = CatalogModel(index: 1, name: 'c-name');
    final product = ProductModel(index: 1, name: 'name', catalog: catalog);
    var argument;

    await tester.pumpWidget(MaterialApp(
      routes: {
        Routes.menuProduct: (context) {
          argument = ModalRoute.of(context)!.settings.arguments;
          return Container();
        },
      },
      home: ProductList(products: [product]),
    ));

    // tap tile
    await tester.tap(find.text('name'));
    await tester.pumpAndSettle();

    expect(identical(product, argument), isTrue);
  });

  testWidgets('should navigate to reorder', (tester) async {
    final catalog = CatalogModel(index: 1, name: 'c-name');
    final product = ProductModel(index: 1, name: 'name', catalog: catalog);
    var count = 0;

    await tester.pumpWidget(MaterialApp(
      routes: {
        Routes.menuProductReorder: (_) {
          count++;
          return Container();
        },
      },
      home: ProductList(products: [product]),
    ));

    // show action
    await tester.longPress(find.text('name'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.reorder_sharp));
    await tester.pumpAndSettle();

    expect(count, equals(1));
  });

  testWidgets('should navigate to modal', (tester) async {
    final catalog = CatalogModel(index: 1, name: 'c-name');
    final product = ProductModel(index: 1, name: 'name', catalog: catalog);
    var count = 0;

    await tester.pumpWidget(MaterialApp(
      routes: {
        Routes.menuProductModal: (_) {
          count++;
          return Container();
        },
      },
      home: ProductList(products: [product]),
    ));

    // show action
    await tester.longPress(find.text('name'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.text_fields_sharp));
    await tester.pumpAndSettle();

    expect(count, equals(1));
  });
}
