import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/menu/catalog/widgets/product_modal.dart';

import '../../../../mocks/mock_models.mocks.dart';
import '../../../../mocks/mock_repos.dart';
import '../../../../mocks/mock_storage.dart';
import '../../../../mocks/mock_widgets.dart';

void main() {
  testWidgets('should update', (tester) async {
    final catalog = MockCatalog();
    final product = Product(name: 'name', id: 'id', catalog: catalog);

    when(catalog.prefix).thenReturn('c-id');
    when(menu.hasProductByName('name-new')).thenReturn(false);

    await tester.pumpWidget(bindWithNavigator(ProductModal(
      catalog: catalog,
      product: product,
    )));

    await tester.enterText(find.byType(TextFormField).at(0), 'name-new');
    await tester.enterText(find.byType(TextFormField).at(1), '1');
    await tester.enterText(find.byType(TextFormField).at(2), '2');

    await tester.tap(find.text('save'));

    final prefix = product.prefix;
    verify(storage.set(any, argThat(predicate<Map<String, Object>>((map) {
      return map['$prefix.price'] == 1 &&
          map['$prefix.cost'] == 2 &&
          map['$prefix.name'] == 'name-new';
    }))));
  });

  testWidgets('should add new item', (tester) async {
    final catalog = Catalog();
    when(menu.hasProductByName('name')).thenReturn(false);

    var navigateCount = 0;

    await tester.pumpWidget(MaterialApp(
      routes: {
        Routes.menuProduct: (context) {
          final product = ModalRoute.of(context)!.settings.arguments as Product;
          expect(product.name, equals('name'));
          expect(product.index, equals(1));
          expect(product.price, equals(1));
          expect(product.cost, equals(2));
          return Text((navigateCount++).toString());
        }
      },
      home: ProductModal(catalog: catalog),
    ));

    await tester.enterText(find.byType(TextFormField).first, 'name');
    await tester.enterText(find.byType(TextFormField).at(1), '1');
    await tester.enterText(find.byType(TextFormField).at(2), '2');

    await tester.tap(find.text('save'));
    await tester.pumpAndSettle();

    final product = catalog.items.first;

    expect(product.name, equals('name'));
    expect(product.price, equals(1));
    expect(product.cost, equals(2));
    expect(navigateCount, equals(1));
  });

  setUpAll(() {
    initializeRepos();
    initializeStorage();
  });
}
