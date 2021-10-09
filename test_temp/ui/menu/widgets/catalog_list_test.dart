import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/menu/widgets/catalog_list.dart';

import '../../../mocks/mock_cache.dart';

void main() {
  testWidgets('should navigate to modal', (tester) async {
    when(cache.getRaw(any)).thenReturn(0);
    when(cache.setRaw(any, any)).thenAnswer((_) => Future.value(true));
    final catalog = Catalog(index: 1, name: 'name');
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
    await tester.pumpAndSettle();

    // tap tile
    await tester.tap(find.text('name'));
    await tester.pumpAndSettle();

    expect(identical(catalog, argument), isTrue);
  });

  testWidgets('should navigate correctly', (tester) async {
    when(cache.getRaw(any)).thenReturn(1);
    final catalog = Catalog(index: 1, name: 'name');
    var navCount = 0;
    final poper = (BuildContext context) => TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text((++navCount).toString()),
        );

    await tester.pumpWidget(MaterialApp(routes: {
      Routes.menuCatalogReorder: poper,
      Routes.menuCatalogModal: poper,
    }, home: CatalogList([catalog])));

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

  setUpAll(() {
    initializeCache();
  });
}
