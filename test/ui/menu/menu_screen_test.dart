import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/menu/menu_screen.dart';
import 'package:provider/provider.dart';

import '../../mocks/mock_cache.dart';
import '../../mocks/mock_storage.dart';

void main() {
  group('Menu Screen', () {
    testWidgets('Add catalog', (WidgetTester tester) async {
      when(cache.getRaw(any)).thenReturn(null);
      when(cache.setRaw(any, any)).thenAnswer((_) => Future.value(true));
      await tester.pumpWidget(MultiProvider(providers: [
        ChangeNotifierProvider<Menu>.value(value: Menu()),
        ChangeNotifierProvider<Stock>.value(value: Stock()),
      ], child: MaterialApp(routes: Routes.routes, home: MenuScreen())));

      // close tip
      await tester.pumpAndSettle();
      await tester.tapAt(Offset(0, 0));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key('empty_body')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(Key('catalog.name')), 'name');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // navigate to catalog screen
      expect(find.byKey(Key('catalog.add')), findsOneWidget);

      final catalog = Menu.instance.items.first;
      expect(catalog.name, equals('name'));
      expect(catalog.index, equals(1));

      verify(storage.add(
        any,
        any,
        argThat(predicate((data) =>
            data is Map &&
            data['name'] == 'name' &&
            data['index'] == 1 &&
            data['createdAt'] > 0 &&
            (data['products'] as Map).isEmpty)),
      ));
    });

    testWidgets('Navigate to catalog', (WidgetTester tester) async {
      Menu().replaceItems({'c-1': Catalog(id: 'c-1', name: 'c-1')});

      await tester.pumpWidget(MultiProvider(providers: [
        ChangeNotifierProvider<Menu>.value(value: Menu.instance),
        ChangeNotifierProvider<Stock>.value(value: Stock()),
      ], child: MaterialApp(routes: Routes.routes, home: MenuScreen())));

      await tester.tap(find.byKey(Key('catalog.c-1')));
      await tester.pumpAndSettle();

      expect(find.byKey(Key('catalog.add')), findsOneWidget);
    });

    testWidgets('Edit catalog', (WidgetTester tester) async {
      final catalog1 = Catalog(id: 'c-1', name: 'c-1');
      final catalog2 = Catalog(id: 'c-2', name: 'c-2');
      Menu().replaceItems({'c-1': catalog1, 'c-2': catalog2});

      await tester.pumpWidget(MultiProvider(providers: [
        ChangeNotifierProvider<Menu>.value(value: Menu.instance),
      ], child: MaterialApp(routes: Routes.routes, home: MenuScreen())));

      await tester.longPress(find.byKey(Key('catalog.c-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.text_fields_sharp));
      await tester.pumpAndSettle();

      // save failed
      await tester.enterText(find.byKey(Key('catalog.name')), 'c-2');
      await tester.tap(find.text('save'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(Key('catalog.name')), 'new-name');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // reset catalog name
      final w = find.byKey(Key('catalog.c-1')).evaluate().first.widget;
      expect(((w as ListTile).title as Text).data, equals('new-name'));

      verify(storage.set(any, argThat(equals({'c-1.name': 'new-name'}))));
    });

    testWidgets('Reorder catalog', (WidgetTester tester) async {
      final catalog1 = Catalog(name: 'c-1', id: 'c-1', index: 1);
      final catalog2 = Catalog(name: 'c-2', id: 'c-2', index: 2);
      final catalog3 = Catalog(name: 'c-3', id: 'c-3', index: 3);
      Menu().replaceItems({'c-1': catalog1, 'c-2': catalog2, 'c-3': catalog3});

      await tester.pumpWidget(MultiProvider(providers: [
        ChangeNotifierProvider<Menu>.value(value: Menu.instance),
      ], child: MaterialApp(routes: Routes.routes, home: MenuScreen())));

      await tester.tap(find.byKey(Key('menu.more')));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.reorder_sharp));
      await tester.pumpAndSettle();

      await tester.drag(find.byIcon(Icons.reorder_sharp).first, Offset(0, 150));

      await tester.tap(find.text('save'));
      await tester.pumpAndSettle();

      final y1 = tester.getCenter(find.byKey(Key('catalog.c-1'))).dy;
      final y2 = tester.getCenter(find.byKey(Key('catalog.c-2'))).dy;
      final itemList = Menu.instance.itemList;
      expect(y1, greaterThan(y2));
      expect(itemList[0].id, equals('c-2'));
      expect(itemList[1].id, equals('c-1'));
      expect(itemList[2].id, equals('c-3'));

      verify(storage.set(
        any,
        argThat(equals({'c-1.index': 2, 'c-2.index': 1})),
      ));
    });

    testWidgets('Delete catalog', (WidgetTester tester) async {
      final catalog1 = Catalog(id: 'c-1', name: 'c-1');
      final catalog2 = Catalog(id: 'c-2', name: 'c-2', products: {
        'p-1': Product(id: 'p-1'),
      });
      Menu().replaceItems({'c-1': catalog1, 'c-2': catalog2});

      await tester.pumpWidget(MultiProvider(providers: [
        ChangeNotifierProvider<Menu>.value(value: Menu.instance),
      ], child: MaterialApp(routes: Routes.routes, home: MenuScreen())));

      await tester.longPress(find.byKey(Key('catalog.c-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(KIcons.delete));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key('delete_dialog.confirm')));
      await tester.pumpAndSettle();

      expect(find.byKey(Key('catalog.c-1')), findsNothing);
      verify(storage.set(any, argThat(equals({catalog1.prefix: null}))));

      await tester.longPress(find.byKey(Key('catalog.c-2')));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(KIcons.delete));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key('delete_dialog.confirm')));
      await tester.pumpAndSettle();

      expect(find.byKey(Key('catalog.c-2')), findsNothing);
      expect(Menu.instance.isEmpty, isTrue);
      verify(storage.set(any, argThat(equals({catalog2.prefix: null}))));
    });

    testWidgets('Search product', (WidgetTester tester) async {
      final now = DateTime.now();
      final product =
          Product(id: 'p-1', name: 'p-1', searchedAt: now, ingredients: {
        'pi-1': ProductIngredient(
            id: 'pi-1',
            ingredient: Ingredient(id: 'i-1', name: 'i-1'),
            quantities: {
              'pq-1': ProductQuantity(
                id: 'pq-1',
                quantity: Quantity(id: 'q-1', name: 'q-1'),
              ),
            })
          ..prepareItem(),
        'pi-2': ProductIngredient(
          id: 'pi-2',
          ingredient: Ingredient(id: 'i-2', name: 'i-2'),
        ),
      })
            ..prepareItem();
      Menu().replaceItems({
        'c-1': Catalog(id: 'c-1', products: {
          'p-1': product,
          'p-2': Product(
            id: 'p-2',
            name: 'p-2',
            searchedAt: DateTime(now.year + 1),
          ),
        })
          ..prepareItem()
      });

      await tester.pumpWidget(MultiProvider(
          providers: [
            ChangeNotifierProvider<Stock>.value(value: Stock()),
            ChangeNotifierProvider<Quantities>.value(value: Quantities()),
            ChangeNotifierProvider<Menu>.value(value: Menu.instance),
          ],
          child: MaterialApp(
            routes: Routes.routes,
            darkTheme: ThemeData.dark(),
            themeMode: ThemeMode.dark,
            home: MenuScreen(),
          )));
      await tester.tap(find.byKey(Key('menu.search')));
      await tester.pumpAndSettle();

      // product 2 has older searchedAt value
      final y1 = tester.getCenter(find.byKey(Key('search.p-1'))).dy;
      final y2 = tester.getCenter(find.byKey(Key('search.p-2'))).dy;
      expect(y1, greaterThan(y2));

      // enter non-matched products
      await tester.enterText(find.byType(TextField), 'empty');
      await tester.pump();

      expect(find.text('搜尋不到相關資訊，打錯字了嗎？'), findsOneWidget);

      // enter match products (including ingredient)
      await tester.enterText(find.byType(TextField), '2');
      await tester.pump();

      expect(find.byKey(Key('search.p-1')), findsOneWidget);
      expect(find.byKey(Key('search.p-2')), findsOneWidget);

      // should match specific quantity
      await tester.enterText(find.byType(TextField), 'q-1');
      await tester.pump();

      expect(find.byKey(Key('search.p-1')), findsOneWidget);
      expect(find.byKey(Key('search.p-2')), findsNothing);

      // navigate to product
      await tester.tap(find.byKey(Key('search.p-1')));
      await tester.pumpAndSettle();

      expect(find.byKey(Key('product_ingredient.pi-1')), findsOneWidget);
      expect(find.byKey(Key('product_ingredient.pi-2')), findsOneWidget);

      // should update searchedAt
      verify(storage.set(any, argThat(predicate((data) {
        return data is Map && data['${product.prefix}.searchedAt'] > 0;
      }))));
    });

    setUp(() {
      // for tip
      when(cache.getRaw(any)).thenReturn(1);
    });

    setUpAll(() {
      initializeCache();
      initializeStorage();
    });
  });
}
