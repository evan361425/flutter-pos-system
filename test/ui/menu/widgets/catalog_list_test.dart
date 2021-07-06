import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/models/menu/catalog_model.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/menu/widgets/catalog_list.dart';

void main() {
  testWidgets('should navigate to modal', (tester) async {
    final catalog = CatalogModel(index: 1, name: 'name');
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

    // tap tile
    await tester.tap(find.text('name'));
    await tester.pumpAndSettle();

    expect(identical(catalog, argument), isTrue);
  });

  testWidgets('should navigate to reorder', (tester) async {
    final catalog = CatalogModel(index: 1, name: 'name');
    var count = 0;

    await tester.pumpWidget(MaterialApp(
      routes: {
        Routes.menuCatalogReorder: (_) {
          count++;
          return Container();
        },
      },
      home: CatalogList([catalog]),
    ));

    // show action
    await tester.longPress(find.text('name'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.reorder_sharp));
    await tester.pumpAndSettle();

    expect(count, equals(1));
  });
}
