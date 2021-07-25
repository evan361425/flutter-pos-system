import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/menu/catalog/widgets/product_modal.dart';

import '../../../../mocks/mock_models.mocks.dart';
import '../../../../mocks/mock_storage.dart';
import '../../../../mocks/mock_widgets.dart';

void main() {
  testWidgets('should update', (tester) async {
    final catalog = MockCatalog();
    final product = Product(index: 1, name: 'name', id: 'id', catalog: catalog);

    when(catalog.prefix).thenReturn('c-id');
    when(catalog.hasName('name-new')).thenReturn(false);

    await tester.pumpWidget(bindWithNavigator(ProductModal(
      catalog: catalog,
      product: product,
    )));

    await tester.enterText(find.byType(TextFormField).first, 'name-new');
    await tester.enterText(find.byType(TextFormField).at(1), '1');
    await tester.enterText(find.byType(TextFormField).at(2), '2');

    await tester.tap(find.byType(TextButton));

    verify(storage.set(any, argThat(predicate<Map<String, Object>>((map) {
      return map['c-id.products.id.price'] == 1 &&
          map['c-id.products.id.cost'] == 2 &&
          map['c-id.products.id.name'] == 'name-new';
    })))).called(1);
  });

  testWidgets('should add new item', (tester) async {
    final catalog = MockCatalog();
    when(catalog.setItem(any)).thenAnswer((_) => Future.value());
    when(catalog.hasName('name')).thenReturn(false);
    when(catalog.newIndex).thenReturn(1);

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

    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    verify(catalog.setItem(any)).called(1);
    expect(navigateCount, equals(1));
  });

  setUpAll(() {
    initializeStorage();
  });
}
