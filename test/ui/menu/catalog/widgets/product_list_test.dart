import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/menu/catalog/widgets/product_list.dart';

void main() {
  testWidgets('should navigate to prodcut', (tester) async {
    final catalog = Catalog(index: 1, name: 'c-name');
    final product = Product(index: 1, name: 'name', catalog: catalog);
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

  testWidgets('should navigate correctly', (tester) async {
    final catalog = Catalog(index: 1, name: 'c-name');
    final product = Product(index: 1, name: 'name', catalog: catalog);
    var navCount = 0;
    final poper = (BuildContext context) => TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text((++navCount).toString()),
        );

    await tester.pumpWidget(MaterialApp(routes: {
      Routes.menuProductReorder: poper,
      Routes.menuProductModal: poper,
    }, home: ProductList(products: [product])));

    // show action
    await tester.longPress(find.text('name'));
    await tester.pumpAndSettle();

    // reorder
    await tester.tap(find.byIcon(Icons.reorder_sharp));
    await tester.pumpAndSettle();

    // pop
    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();

    // show action
    await tester.longPress(find.text('name'));
    await tester.pumpAndSettle();

    // edit
    await tester.tap(find.byIcon(Icons.text_fields_sharp));
    await tester.pumpAndSettle();

    expect(find.text('2'), findsOneWidget);
  });
}
