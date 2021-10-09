import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/menu/menu_screen.dart';
import 'package:provider/provider.dart';

import '../../mocks/mock_cache.dart';
import '../../mocks/mock_models.mocks.dart';
import '../../mocks/mock_repos.dart';

void main() {
  testWidgets('should show empty body if empty', (tester) async {
    when(menu.isEmpty).thenReturn(true);
    when(menu.isNotEmpty).thenReturn(false);
    when(cache.getRaw(any)).thenReturn(0);

    await tester.pumpWidget(MultiProvider(providers: [
      ChangeNotifierProvider<Menu>.value(value: menu),
    ], child: MaterialApp(home: MenuScreen())));

    expect(find.byType(EmptyBody), findsOneWidget);
  });

  testWidgets('should navigate correctly', (tester) async {
    when(menu.isEmpty).thenReturn(false);
    when(menu.isNotEmpty).thenReturn(true);
    when(menu.length).thenReturn(1);
    when(menu.itemList).thenReturn([Catalog(name: 'hi there')]);
    when(cache.getRaw(any)).thenReturn(1);
    var navCount = 0;
    final poper = (BuildContext context) => TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text((++navCount).toString()),
        );

    await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<Menu>.value(value: menu),
        ],
        child: MaterialApp(routes: {
          Routes.menuCatalogReorder: poper,
          Routes.menuSearch: poper,
        }, home: MenuScreen())));

    await tester.tap(find.byIcon(KIcons.more));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.reorder_sharp));
    await tester.pumpAndSettle();

    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('menu.search')));
    await tester.pumpAndSettle();

    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('should addable', (tester) async {
    final catalog = MockCatalog();
    final product = MockProduct();
    when(cache.getRaw(any)).thenReturn(1);
    when(product.name).thenReturn('p-name');
    when(catalog.id).thenReturn('id');
    when(catalog.name).thenReturn('name');
    when(catalog.itemList).thenReturn([product]);
    when(menu.isEmpty).thenReturn(false);
    when(menu.isNotEmpty).thenReturn(true);
    when(menu.length).thenReturn(1);
    when(menu.itemList).thenReturn([catalog]);

    var navigateCount = 0;

    await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<Menu>.value(value: menu),
        ],
        child: MaterialApp(
          routes: {
            Routes.menuCatalogModal: (_) => Text((navigateCount++).toString()),
          },
          home: MenuScreen(),
        )));

    // tap to add ingredient
    await tester.tap(find.byIcon(KIcons.add));
    await tester.pumpAndSettle();

    expect(navigateCount, equals(1));
  });

  setUpAll(() {
    initializeCache();
    initializeRepos();
  });
}
