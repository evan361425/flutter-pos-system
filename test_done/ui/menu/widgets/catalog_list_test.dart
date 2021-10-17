import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/menu/widgets/catalog_list.dart';

import '../../../mocks/mock_cache.dart';
import '../../../mocks/mock_storage.dart';

void main() {
  testWidgets('should navigate to modal', (tester) async {
    // able to show tip
    when(cache.getRaw(any)).thenReturn(0);
    when(cache.setRaw(any, any)).thenAnswer((_) => Future.value(true));

    final catalog = Catalog();
    var argument;
    await tester.pumpWidget(MaterialApp(
      routes: {
        Routes.menuCatalog: (context) {
          argument = ModalRoute.of(context)!.settings.arguments;
          return Container();
        },
      },
      home: CatalogList([catalog]),
    ));
    // show tip
    await tester.pumpAndSettle();

    // close tip
    await tester.tapAt(Offset.zero);
    await tester.pumpAndSettle();

    // tap tile
    await tester.tap(find.text('catalog'));
    await tester.pumpAndSettle();

    expect(identical(catalog, argument), isTrue);
  });

  testWidgets('should navigate correctly', (tester) async {
    // hide tip
    when(cache.getRaw(any)).thenReturn(1);
    var navCount = 0;
    final catalog = Catalog();
    final poper = (BuildContext context) => TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text((++navCount).toString()),
        );

    await tester.pumpWidget(MaterialApp(routes: {
      Routes.menuCatalogReorder: poper,
      Routes.menuCatalogModal: poper,
    }, home: CatalogList([catalog])));

    // show action
    await tester.longPress(find.text('catalog'));
    await tester.pumpAndSettle();

    // reorder
    await tester.tap(find.byIcon(Icons.reorder_sharp));
    await tester.pumpAndSettle();

    // pop
    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();

    // show action
    await tester.longPress(find.text('catalog'));
    await tester.pumpAndSettle();

    // edit
    await tester.tap(find.byIcon(Icons.text_fields_sharp));
    await tester.pumpAndSettle();

    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('should delete catalog', (tester) async {
    // hide tip
    when(cache.getRaw(any)).thenReturn(1);
    when(storage.set(any, any)).thenAnswer((_) => Future.value());
    LOG_LEVEL = 0;
    var notifiedCount = 0;

    final menu = Menu();
    final catalog1 = Catalog(id: 'c-1', name: 'catalog-1');
    final catalog2 = Catalog(id: 'c-2', name: 'catalog-2', products: {
      'p-1': Product(),
    });
    menu.replaceItems({'c-1': catalog1});
    menu.addListener(() => notifiedCount++);

    await tester.pumpWidget(MaterialApp(
      home: CatalogList([catalog1, catalog2]),
    ));

    // show action
    await tester.longPress(find.text('catalog-1'));
    await tester.pumpAndSettle();

    // delete
    await tester.tap(find.byIcon(KIcons.delete));
    await tester.pumpAndSettle();

    // confirm
    await tester.tap(find.text('delete'));
    await tester.pumpAndSettle();

    // show action
    await tester.longPress(find.text('catalog-2'));
    await tester.pumpAndSettle();

    // edit
    await tester.tap(find.byIcon(KIcons.delete));
    await tester.pumpAndSettle();

    expect(find.text('delete_confirm-catalog-2-1'), findsOneWidget);
    expect(notifiedCount, equals(1));
  });

  setUpAll(() {
    initializeCache();
    initializeStorage();
  });
}
