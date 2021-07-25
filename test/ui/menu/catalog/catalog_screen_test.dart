import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/components/style/circular_loading.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/menu/catalog_model.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/menu/catalog/catalog_screen.dart';
import 'package:provider/provider.dart';

import '../../../mocks/mock_models.mocks.dart';
import '../../../mocks/mock_repos.dart';

void main() {
  testWidgets('should show loading if setting stock mode', (tester) async {
    when(menu.setUpStockMode(any)).thenReturn(false);
    final catalog = CatalogModel(index: 1, name: 'name');

    await tester.pumpWidget(MultiProvider(providers: [
      ChangeNotifierProvider<CatalogModel>.value(value: catalog),
    ], child: MaterialApp(home: CatalogScreen())));

    expect(find.byType(CircularLoading), findsOneWidget);
  });

  testWidgets('should show empty body if empty', (tester) async {
    when(menu.setUpStockMode(any)).thenReturn(true);
    final catalog = CatalogModel(index: 1, name: 'name');

    await tester.pumpWidget(MultiProvider(providers: [
      ChangeNotifierProvider<CatalogModel>.value(value: catalog),
    ], child: MaterialApp(home: CatalogScreen())));

    expect(find.byType(EmptyBody), findsOneWidget);
  });

  testWidgets('should navigate to modal', (tester) async {
    when(menu.setUpStockMode(any)).thenReturn(true);
    final catalog = CatalogModel(index: 1, name: 'name');
    var argument;

    await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<CatalogModel>.value(value: catalog),
        ],
        child: MaterialApp(
          routes: {
            Routes.menuCatalogModal: (context) {
              argument = ModalRoute.of(context)!.settings.arguments;
              return Container();
            },
          },
          home: CatalogScreen(),
        )));

    // tap tile
    await tester.tap(find.byIcon(KIcons.more));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.text_fields_sharp));
    await tester.pumpAndSettle();

    expect(identical(catalog, argument), isTrue);
  });

  testWidgets('should navigate to reorder', (tester) async {
    when(menu.setUpStockMode(any)).thenReturn(true);
    final catalog = CatalogModel(index: 1, name: 'name');
    var argument;

    await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<CatalogModel>.value(value: catalog),
        ],
        child: MaterialApp(
          routes: {
            Routes.menuProductReorder: (context) {
              argument = ModalRoute.of(context)!.settings.arguments;
              return Container();
            },
          },
          home: CatalogScreen(),
        )));

    // tap tile
    await tester.tap(find.byIcon(KIcons.more));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.reorder_sharp));
    await tester.pumpAndSettle();

    expect(identical(catalog, argument), isTrue);
  });

  testWidgets('should addable', (tester) async {
    final product = MockProductModel();
    final catalog = CatalogModel(
      index: 1,
      name: 'c-name',
      id: 'c-id',
      products: {'id': product},
    );
    when(menu.setUpStockMode(any)).thenReturn(true);
    when(product.name).thenReturn('name');
    when(product.items).thenReturn([]);

    var navigateCount = 0;

    await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<CatalogModel>.value(value: catalog),
        ],
        child: MaterialApp(
          routes: {
            Routes.menuProductModal: (_) => Text((navigateCount++).toString()),
          },
          home: CatalogScreen(),
        )));

    // tap to add ingredient
    await tester.tap(find.byIcon(KIcons.add));
    await tester.pumpAndSettle();

    expect(navigateCount, equals(1));
  });

  setUpAll(() {
    initializeRepos();
  });
}
