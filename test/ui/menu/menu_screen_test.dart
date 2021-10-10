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

void main() {
  testWidgets('should show empty body if empty', (tester) async {
    final menu = Menu();
    // show tips
    when(cache.getRaw(any)).thenReturn(0);

    await tester.pumpWidget(MultiProvider(providers: [
      ChangeNotifierProvider<Menu>.value(value: menu),
    ], child: MaterialApp(home: MenuScreen())));

    expect(find.byType(EmptyBody), findsOneWidget);
  });

  testWidgets('should navigate correctly', (tester) async {
    final menu = Menu()..addItem(Catalog());
    // hide tips
    when(cache.getRaw(any)).thenReturn(1);
    var navCount = 0;
    final poper = (BuildContext context) => TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text((++navCount).toString()),
        );

    await tester.pumpWidget(MultiProvider(
        providers: [ChangeNotifierProvider<Menu>.value(value: menu)],
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
    final menu = Menu();
    // hide tips
    when(cache.getRaw(any)).thenReturn(1);
    await tester.pumpWidget(MultiProvider(
        providers: [ChangeNotifierProvider<Menu>.value(value: menu)],
        child: MaterialApp(
          routes: {Routes.menuCatalogModal: (_) => Text('hi')},
          home: MenuScreen(),
        )));

    // tap to add ingredient
    await tester.tap(find.byIcon(KIcons.add));
    await tester.pumpAndSettle();

    expect(find.text('hi'), findsOneWidget);
  });

  setUpAll(() {
    initializeCache();
  });
}
