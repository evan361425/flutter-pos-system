import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/menu/widgets/catalog_modal.dart';

import '../../../mocks/mock_storage.dart';
import '../../../mocks/mock_widgets.dart';

void main() {
  testWidgets('should update', (tester) async {
    LOG_LEVEL = 0;
    var notifiedCount = 0;
    final menu = Menu();
    final catalog1 = Catalog(id: 'c-1');
    final catalog2 = Catalog(id: 'c-2', name: 'exist-name');
    menu.replaceItems({'c-1': catalog1, 'c-2': catalog2});
    menu.addListener(() => notifiedCount++);

    await tester.pumpWidget(bindWithNavigator(CatalogModal(
      catalog: catalog1,
    )));

    await tester.enterText(find.byKey(Key('catalog.name')), 'exist-name');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    // error message, label, hint
    expect(find.text('name'), findsNWidgets(3));

    await tester.enterText(find.byKey(Key('catalog.name')), 'new-name');
    await tester.testTextInput.receiveAction(TextInputAction.done);

    verify(storage.set(any, argThat(predicate<Map<String, Object>>((map) {
      return map['c-1.name'] == 'new-name';
    }))));
    expect(notifiedCount, equals(1));
  });

  testWidgets('should add new item', (tester) async {
    LOG_LEVEL = 0;
    var argument;
    var notifiedCount = 0;
    final menu = Menu();
    menu.addListener(() => notifiedCount++);

    await tester.pumpWidget(MaterialApp(
      routes: {
        Routes.menuCatalog: (context) {
          argument = ModalRoute.of(context)!.settings.arguments;
          return Text('hi');
        }
      },
      home: CatalogModal(),
    ));

    await tester.enterText(find.byKey(Key('catalog.name')), 'name');
    await tester.tap(find.text('save'));
    await tester.pumpAndSettle();

    verify(storage.add(any, any, argThat(predicate<Map<String, Object>>((map) {
      return map['name'] == 'name' && map['index'] == 1;
    }))));
    expect(identical(argument, menu.items.first), isTrue);
    expect(notifiedCount, equals(1));
  });

  setUpAll(() {
    initializeStorage();
  });
}
