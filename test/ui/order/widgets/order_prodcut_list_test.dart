import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/menu/catalog_model.dart';
import 'package:possystem/models/menu/product_model.dart';
import 'package:possystem/ui/order/widgets/order_product_list.dart';

import '../../../mocks/mock_models.mocks.dart';
import '../../../mocks/mock_repos.dart';

void main() {
  testWidgets('should have same height even empty', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: OrderProductList(products: [], handleSelected: (_) {}),
    ));

    final emptyHeight =
        find.byType(SingleChildScrollView).evaluate().first.size!.height;

    final product = ProductModel(index: 1, name: 'name');
    await tester.pumpWidget(MaterialApp(
      home: OrderProductList(products: [product], handleSelected: (_) {}),
    ));
    final height =
        find.byType(SingleChildScrollView).evaluate().first.size!.height;

    expect(height, equals(emptyHeight));
  });

  testWidgets('should get selected product', (tester) async {
    final product = ProductModel(index: 1, name: 'name');
    final key = GlobalKey<OrderProductListState>();
    when(cart.add(product)).thenReturn(MockOrderProductModel());

    ProductModel? selected;

    await tester.pumpWidget(MaterialApp(
      home: OrderProductList(
        key: key,
        products: [],
        handleSelected: (product) => selected = product,
      ),
    ));

    key.currentState?.updateProducts(
        CatalogModel(index: 1, name: 'cat', products: {'id': product}));
    await tester.pump();

    await tester.tap(find.text('name'));

    verify(cart.toggleAll(false));
    verify(cart.add(product));
    expect(selected, product);
  });

  setUpAll(() {
    initializeRepos();
  });
}
