import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/menu/catalog/widgets/product_modal.dart';

import '../../../../mocks/mock_storage.dart';
import '../../../../mocks/mock_widgets.dart';

void main() {
  testWidgets('should update', (tester) async {
    LOG_LEVEL = 0;
    var notifiedCount = 0;

    final menu = Menu();
    final product1 = Product(id: 'p-1');
    final product2 = Product(id: 'p-2', name: 'exist-name');
    final catalog = Catalog(id: 'c-1', products: {
      'p-1': product1,
      'p-2': product2,
    });
    product1.catalog = catalog;
    menu.replaceItems({'c-1': catalog});
    catalog.addListener(() => notifiedCount++);
    menu.addListener(() => notifiedCount++);

    await tester.pumpWidget(bindWithNavigator(ProductModal(
      catalog: catalog,
      product: product1,
    )));

    await tester.enterText(find.byKey(Key('product.name')), 'exist-name');
    await tester.enterText(find.byKey(Key('product.price')), '1');
    await tester.enterText(find.byKey(Key('product.cost')), '1');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    // error message, label, hint
    expect(find.text('name'), findsNWidgets(3));

    await tester.enterText(find.byKey(Key('product.name')), 'new-name');
    await tester.tap(find.text('save'));

    final prefix = product1.prefix;
    verify(storage.set(any, argThat(predicate<Map<String, Object>>((map) {
      return map['$prefix.price'] == 1 &&
          map['$prefix.cost'] == 1 &&
          map['$prefix.name'] == 'new-name';
    }))));
    expect(notifiedCount, equals(2));
  });

  testWidgets('should add new item', (tester) async {
    LOG_LEVEL = 0;
    var argument;
    var notifiedCount = 0;

    final menu = Menu();
    final catalog = Catalog(id: 'c-1');
    menu.replaceItems({'c-1': catalog});
    catalog.addListener(() => notifiedCount++);
    menu.addListener(() => notifiedCount++);

    await tester.pumpWidget(MaterialApp(
      routes: {
        Routes.menuProduct: (context) {
          argument = ModalRoute.of(context)!.settings.arguments;
          return Text('hi');
        }
      },
      home: ProductModal(catalog: catalog),
    ));

    await tester.enterText(find.byKey(Key('product.name')), 'name');
    await tester.enterText(find.byKey(Key('product.price')), '1');
    await tester.enterText(find.byKey(Key('product.cost')), '1');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    verify(storage.set(any, argThat(predicate((data) {
      final map = (data as Map).values.first as Map<String, Object>;
      return map['price'] == 1 &&
          map['cost'] == 1 &&
          map['name'] == 'name' &&
          map['index'] == 1;
    }))));
    expect(identical(argument, catalog.items.first), isTrue);
    expect(notifiedCount, equals(2));
  });

  setUpAll(() {
    initializeStorage();
  });
}
