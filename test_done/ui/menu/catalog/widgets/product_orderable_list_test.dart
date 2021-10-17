import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/ui/menu/catalog/widgets/product_orderable_list.dart';

import '../../../../mocks/mock_storage.dart';
import '../../../../mocks/mock_widgets.dart';

void main() {
  testWidgets('should reordering', (tester) async {
    final product1 = Product(name: 'p-1', id: 'p-1', index: 1);
    final product2 = Product(name: 'p-2', id: 'p-2', index: 2);
    final catalog = Catalog(products: {'p-1': product1, 'p-2': product2});
    product1.catalog = catalog;
    product2.catalog = catalog;
    when(storage.set(any, any)).thenAnswer((_) => Future.value());

    // need notify menu
    final menu = Menu();
    var notifiedCount = 0;
    catalog.addListener(() => notifiedCount++);
    menu.addListener(() => notifiedCount++);

    await tester.pumpWidget(bindWithNavigator(ProductOrderableList(catalog)));

    await tester.drag(
      find.byIcon(Icons.reorder_sharp).first,
      const Offset(0, 500.0),
    );

    await tester.tap(find.text('save'));
    await tester.pumpAndSettle();

    expect(catalog.itemList.map((e) => e.name), ['p-2', 'p-1']);
    expect(notifiedCount, equals(2));
  });

  setUpAll(() {
    initializeStorage();
  });
}
