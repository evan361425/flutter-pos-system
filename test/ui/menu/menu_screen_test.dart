import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/constants/icons.dart';
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
    when(cache.shouldCheckTutorial(any, any)).thenReturn(true);

    await tester.pumpWidget(MultiProvider(providers: [
      ChangeNotifierProvider<Menu>.value(value: menu),
    ], child: MaterialApp(home: MenuScreen())));

    expect(find.byType(EmptyBody), findsOneWidget);
  });

  testWidgets('should addable', (tester) async {
    final catalog = MockCatalog();
    final product = MockProduct();
    when(cache.shouldCheckTutorial(any, any)).thenReturn(false);
    when(product.name).thenReturn('p-name');
    when(catalog.id).thenReturn('id');
    when(catalog.name).thenReturn('name');
    when(catalog.itemList).thenReturn([product]);
    when(menu.isEmpty).thenReturn(false);
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

  testWidgets('should showing tutorial', (tester) async {
    final catalog = MockCatalog();
    final product = MockProduct();
    when(cache.shouldCheckTutorial(any, any)).thenReturn(true);
    when(cache.neededTutorial(any, any)).thenReturn(['catalog_intro']);
    when(product.name).thenReturn('p-name');
    when(catalog.id).thenReturn('id');
    when(catalog.name).thenReturn('name');
    when(catalog.itemList).thenReturn([product]);
    when(menu.isEmpty).thenReturn(false);
    when(menu.length).thenReturn(1);
    when(menu.itemList).thenReturn([catalog]);

    await tester.pumpWidget(MultiProvider(providers: [
      ChangeNotifierProvider<Menu>.value(value: menu),
    ], child: MaterialApp(home: MenuScreen())));

    await tester.pump(Duration(milliseconds: 101));

    expect(find.text('SKIP'), findsOneWidget);
  });

  setUpAll(() {
    initializeCache();
    initializeRepos();
  });
}
