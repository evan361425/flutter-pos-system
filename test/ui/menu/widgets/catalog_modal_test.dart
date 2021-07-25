import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/menu/widgets/catalog_modal.dart';

import '../../../mocks/mock_storage.dart';
import '../../../mocks/mock_widgets.dart';
import '../../../mocks/mock_repos.dart';

void main() {
  testWidgets('should update', (tester) async {
    final catalog = Catalog(index: 1, name: 'name', id: 'id');

    when(menu.hasName('name-new')).thenReturn(false);

    await tester.pumpWidget(bindWithNavigator(CatalogModal(
      catalog: catalog,
    )));

    await tester.enterText(find.byType(TextFormField).first, 'name-new');

    await tester.tap(find.byType(TextButton));

    verify(storage.set(any, argThat(predicate<Map<String, Object>>((map) {
      return map['id.name'] == 'name-new';
    })))).called(1);
  });

  testWidgets('should add new item', (tester) async {
    when(menu.setItem(any)).thenAnswer((_) => Future.value());
    when(menu.hasName('name')).thenReturn(false);
    when(menu.newIndex).thenReturn(1);

    var navigateCount = 0;

    await tester.pumpWidget(MaterialApp(
      routes: {
        Routes.menuCatalog: (context) {
          final catalog = ModalRoute.of(context)!.settings.arguments as Catalog;
          expect(catalog.name, equals('name'));
          expect(catalog.index, equals(1));
          return Text((navigateCount++).toString());
        }
      },
      home: CatalogModal(),
    ));

    await tester.enterText(find.byType(TextFormField).first, 'name');

    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    verify(menu.setItem(argThat(predicate<Catalog>((model) {
      return model.name == 'name' && model.index == 1;
    })))).called(1);
    expect(navigateCount, equals(1));
  });

  setUpAll(() {
    initializeRepos();
    initializeStorage();
  });
}
