import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/components/style/circular_loading.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/menu_model.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/menu/menu_screen.dart';
import 'package:provider/provider.dart';

import '../../mocks/mockito/mock_catalog_model.dart';
import '../../mocks/mockito/mock_product_model.dart';
import '../../mocks/mocks.dart';

void main() {
  testWidgets('should show loading if not ready', (tester) async {
    when(menu.isReady).thenReturn(false);

    await tester.pumpWidget(MultiProvider(providers: [
      ChangeNotifierProvider<MenuModel>.value(value: menu),
    ], child: MaterialApp(home: MenuScreen())));

    expect(find.byType(CircularLoading), findsOneWidget);
  });

  testWidgets('should show empty body if empty', (tester) async {
    when(menu.isReady).thenReturn(true);
    when(menu.isEmpty).thenReturn(true);

    await tester.pumpWidget(MultiProvider(providers: [
      ChangeNotifierProvider<MenuModel>.value(value: menu),
    ], child: MaterialApp(home: MenuScreen())));

    expect(find.byType(EmptyBody), findsOneWidget);
  });

  testWidgets('should addable', (tester) async {
    final catalog = MockCatalogModel();
    final product = MockProductModel();
    when(product.name).thenReturn('p-name');
    when(catalog.id).thenReturn('id');
    when(catalog.name).thenReturn('name');
    when(catalog.itemList).thenReturn([product]);
    when(menu.isReady).thenReturn(true);
    when(menu.isEmpty).thenReturn(false);
    when(menu.length).thenReturn(1);
    when(menu.itemList).thenReturn([catalog]);

    var navigateCount = 0;

    await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<MenuModel>.value(value: menu),
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
    initialize();
  });
}
