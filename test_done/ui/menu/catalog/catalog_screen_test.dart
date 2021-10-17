import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/menu/catalog/catalog_screen.dart';
import 'package:provider/provider.dart';

void main() {
  Widget bindWithProvider(Catalog catalog, Widget child) {
    return MultiProvider(providers: [
      ChangeNotifierProvider<Catalog>.value(value: catalog),
      ChangeNotifierProvider<Stock>.value(value: Stock()),
    ], child: child);
  }

  testWidgets('should show empty body if empty', (tester) async {
    final catalog = Catalog();

    await tester.pumpWidget(bindWithProvider(
      catalog,
      MaterialApp(home: CatalogScreen()),
    ));

    expect(find.byType(EmptyBody), findsOneWidget);
  });

  testWidgets('should navigate correctly', (tester) async {
    final catalog = Catalog(products: {'p-1': Product(id: 'p-1')});
    var navCount = 0;
    final poper = (BuildContext context) => TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text((++navCount).toString()),
        );

    await tester.pumpWidget(bindWithProvider(
        catalog,
        MaterialApp(routes: {
          Routes.menuCatalogModal: poper,
          Routes.menuProductReorder: poper,
        }, home: CatalogScreen())));

    await tester.tap(find.byIcon(KIcons.more));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.text_fields_sharp));
    await tester.pumpAndSettle();

    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(KIcons.more));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.reorder_sharp));
    await tester.pumpAndSettle();

    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('should addable', (tester) async {
    final catalog = Catalog();
    await tester.pumpWidget(bindWithProvider(
        catalog,
        MaterialApp(
          routes: {Routes.menuProductModal: (_) => Text('hi')},
          home: CatalogScreen(),
        )));

    // tap to add ingredient
    await tester.tap(find.byIcon(KIcons.add));
    await tester.pumpAndSettle();

    expect(find.text('hi'), findsOneWidget);
  });
}
