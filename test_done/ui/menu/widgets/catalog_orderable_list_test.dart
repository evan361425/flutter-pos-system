import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/ui/menu/widgets/catalog_orderable_list.dart';

import '../../../mocks/mock_storage.dart';
import '../../../mocks/mock_widgets.dart';

void main() {
  testWidgets('should reordering', (tester) async {
    var notifiedCount = 0;
    final menu = Menu();
    final catalog1 = Catalog(name: 'c-1', id: 'c-1', index: 1);
    final catalog2 = Catalog(name: 'c-2', id: 'c-2', index: 2);
    menu.replaceItems({'c-1': catalog1, 'c-2': catalog2});
    when(storage.set(any, any)).thenAnswer((_) => Future.value());
    menu.addListener(() => notifiedCount++);

    await tester.pumpWidget(bindWithNavigator(CatalogOrderableList()));

    await tester.drag(
      find.byIcon(Icons.reorder_sharp).first,
      const Offset(0, 500.0),
    );

    await tester.tap(find.text('save'));
    await tester.pumpAndSettle();

    expect(menu.itemList.map((e) => e.name), ['c-2', 'c-1']);
    expect(notifiedCount, equals(1));
  });

  setUpAll(() {
    initializeStorage();
  });
}
