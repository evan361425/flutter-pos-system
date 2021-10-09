import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/menu/catalog/catalog_screen.dart';
import 'package:provider/provider.dart';

import '../../../mocks/mock_models.mocks.dart';
import '../../../mocks/mock_repos.dart';

void main() {
  Widget bindWithProvider(Catalog catalog, Widget child) {
    return MultiProvider(providers: [
      ChangeNotifierProvider<Catalog>.value(value: catalog),
      ChangeNotifierProvider<Stock>.value(value: stock),
    ], child: child);
  }

  testWidgets('should show empty body if empty', (tester) async {
    final catalog = Catalog(index: 1, name: 'name');

    await tester.pumpWidget(bindWithProvider(
      catalog,
      MaterialApp(home: CatalogScreen()),
    ));

    expect(find.byType(EmptyBody), findsOneWidget);
  });

  testWidgets('should navigate to modal', (tester) async {
    final catalog = Catalog(index: 1, name: 'name');
    var argument;

    await tester.pumpWidget(bindWithProvider(
        catalog,
        MaterialApp(
          routes: {
            Routes.menuCatalogModal: (context) {
              argument = ModalRoute.of(context)!.settings.arguments;
              return Container();
            },
          },
          home: CatalogScreen(),
        )));

    // tap tile
    await tester.tap(find.byIcon(KIcons.edit));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.text_fields_sharp));
    await tester.pumpAndSettle();

    expect(identical(catalog, argument), isTrue);
  });

  testWidgets('should navigate to reorder', (tester) async {
    final catalog = Catalog(index: 1, name: 'name');
    var argument;

    await tester.pumpWidget(bindWithProvider(
        catalog,
        MaterialApp(
          routes: {
            Routes.menuProductReorder: (context) {
              argument = ModalRoute.of(context)!.settings.arguments;
              return Container();
            },
          },
          home: CatalogScreen(),
        )));

    // tap tile
    await tester.tap(find.byIcon(KIcons.edit));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.reorder_sharp));
    await tester.pumpAndSettle();

    expect(identical(catalog, argument), isTrue);
  });

  testWidgets('should addable', (tester) async {
    final product = MockProduct();
    final catalog = Catalog(
      index: 1,
      name: 'c-name',
      id: 'c-id',
      products: {'id': product},
    );
    when(product.name).thenReturn('name');
    when(product.items).thenReturn([]);

    var navigateCount = 0;

    await tester.pumpWidget(bindWithProvider(
        catalog,
        MaterialApp(
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
