import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/models/menu/catalog_model.dart';
import 'package:possystem/ui/order/widgets/order_catalog_list.dart';

void main() {
  testWidgets('should have same height even empty', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: OrderCatalogList(catalogs: [], handleSelected: (_) {}),
    ));

    final emptyHeight =
        find.byType(SingleChildScrollView).evaluate().first.size!.height;

    final catalog = CatalogModel(index: 1, name: 'name', id: 'id');
    await tester.pumpWidget(MaterialApp(
      home: OrderCatalogList(catalogs: [catalog], handleSelected: (_) {}),
    ));
    final height =
        find.byType(SingleChildScrollView).evaluate().first.size!.height;

    expect(height, equals(emptyHeight));
  });

  testWidgets('should get selected catalog', (tester) async {
    final catalog1 = CatalogModel(index: 1, name: 'name1', id: 'id1');
    final catalog2 = CatalogModel(index: 1, name: 'name2', id: 'id2');

    CatalogModel? selected;
    await tester.pumpWidget(MaterialApp(
      home: OrderCatalogList(
          catalogs: [catalog1, catalog2],
          handleSelected: (catalog) => selected = catalog),
    ));

    await tester.tap(find.text('name2'));
    await tester.pump();

    expect(selected, equals(catalog2));
  });
}
