import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/menu/catalog/widgets/product_list.dart';

import '../../../../mocks/mock_storage.dart';

void main() {
  testWidgets('should navigate to modal', (tester) async {
    final product = Product();
    var argument;
    await tester.pumpWidget(MaterialApp(
      routes: {
        Routes.menuProduct: (context) {
          argument = ModalRoute.of(context)!.settings.arguments;
          return Container();
        },
      },
      home: ProductList([product]),
    ));

    // tap tile
    await tester.tap(find.text('product'));
    await tester.pumpAndSettle();

    expect(identical(product, argument), isTrue);
  });

  testWidgets('should navigate correctly', (tester) async {
    var navCount = 0;
    final catalog = Catalog();
    final product = Product(id: 'p-1', catalog: catalog);
    catalog.replaceItems({'p-1': product});
    final poper = (BuildContext context) => TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text((++navCount).toString()),
        );

    await tester.pumpWidget(MaterialApp(routes: {
      Routes.menuProductReorder: poper,
      Routes.menuProductModal: poper,
    }, home: ProductList([product])));

    // show action
    await tester.longPress(find.text('product'));
    await tester.pumpAndSettle();

    // reorder
    await tester.tap(find.byIcon(Icons.reorder_sharp));
    await tester.pumpAndSettle();

    // pop
    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();

    // show action
    await tester.longPress(find.text('product'));
    await tester.pumpAndSettle();

    // edit
    await tester.tap(find.byIcon(Icons.text_fields_sharp));
    await tester.pumpAndSettle();

    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('should delete product', (tester) async {
    when(storage.set(any, any)).thenAnswer((_) => Future.value());
    LOG_LEVEL = 0;
    var notifiedCount = 0;

    final menu = Menu();
    final catalog = Catalog();
    final product = Product(id: 'p-1', name: 'p-1', catalog: catalog);
    catalog.replaceItems({'p-1': product});
    catalog.addListener(() => notifiedCount++);
    menu.addListener(() => notifiedCount++);

    await tester.pumpWidget(MaterialApp(
      home: ProductList([product]),
    ));

    // show action
    await tester.longPress(find.text('p-1'));
    await tester.pumpAndSettle();

    // delete
    await tester.tap(find.byIcon(KIcons.delete));
    await tester.pumpAndSettle();

    // confirm
    await tester.tap(find.text('delete'));
    await tester.pumpAndSettle();

    expect(catalog.length, isZero);
    expect(notifiedCount, equals(2));
  });

  setUpAll(() {
    initializeStorage();
  });
}
