import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/constants/app_themes.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/breakpoint.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/printer.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/menu/menu_page.dart';
import 'package:provider/provider.dart';

import '../../mocks/mock_cache.dart';
import '../../mocks/mock_storage.dart';
import '../../test_helpers/breakpoint_mocker.dart';
import '../../test_helpers/file_mocker.dart';
import '../../test_helpers/translator.dart';

void main() {
  group('Menu Page', () {
    Widget buildApp([String? popImage]) {
      final baseRoute = Routes.getDesiredRoute(0).routes[0] as GoRoute;
      return MaterialApp.router(
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.dark,
        routerConfig: GoRouter(navigatorKey: Routes.rootNavigatorKey, routes: [
          GoRoute(
            path: '/',
            builder: (context, __) {
              final singleView = Breakpoint.find(width: MediaQuery.sizeOf(context).width) <= Breakpoint.medium;
              return singleView ? const MenuPage() : const Scaffold(body: MenuPage());
            },
            routes: [
              GoRoute(
                name: Routes.imageGallery,
                path: 'image_gallery',
                builder: (context, __) => TextButton(
                  onPressed: () => context.pop(popImage),
                  child: const Text('tap me'),
                ),
              ),
            ],
          ),
          GoRoute(
            path: baseRoute.path,
            redirect: baseRoute.redirect,
            routes: baseRoute.routes.where((e) => e is! GoRoute || e.name != Routes.imageGallery).toList(),
          ),
        ]),
      );
    }

    for (final device in [Device.desktop, Device.mobile]) {
      group(device.name, () {
        testWidgets('Add catalog with image', (WidgetTester tester) async {
          deviceAs(device, tester);
          await tester.pumpWidget(MultiProvider(
            providers: [
              ChangeNotifierProvider<Menu>.value(value: Menu()),
              ChangeNotifierProvider<Stock>.value(value: Stock()),
            ],
            child: buildApp('test-image'),
          ));

          await tester.tap(find.byKey(const Key('empty_body')));
          await tester.pumpAndSettle();

          await tester.tap(find.byKey(const Key('image_holder.edit')));
          await tester.pumpAndSettle();
          await tester.tap(find.text('tap me'));
          await tester.pumpAndSettle();

          await tester.enterText(find.byKey(const Key('catalog.name')), 'name');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();
          await tester.pumpAndSettle();

          // catalog view
          expect(find.byKey(const Key('catalog.empty')), findsOneWidget);

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
                data['imagePath'] == 'test-image' &&
                (data['products'] as Map).isEmpty)),
          ));
        });

        testWidgets('Edit catalog', (WidgetTester tester) async {
          deviceAs(device, tester);
          final newImage = await createImage('test-image');
          final catalog1 = Catalog(id: 'c-1', name: 'c-1', imagePath: 'wrong-path');
          final catalog2 = Catalog(id: 'c-2', name: 'c-2');
          Menu().replaceItems({'c-1': catalog1, 'c-2': catalog2});

          await tester.pumpWidget(MultiProvider(
            providers: [
              ChangeNotifierProvider<Menu>.value(value: Menu.instance),
            ],
            child: buildApp(newImage),
          ));

          await tester.longPress(find.byKey(const Key('catalog.c-1')));
          await tester.pumpAndSettle();
          await tester.tap(find.byIcon(Icons.text_fields_outlined));
          await tester.pumpAndSettle();

          // edit image
          await tester.tap(find.byKey(const Key('image_holder.edit')));
          await tester.pumpAndSettle();
          await tester.tap(find.text('tap me'));
          await tester.pumpAndSettle();

          // save failed
          await tester.enterText(find.byKey(const Key('catalog.name')), 'c-2');
          await tester.tap(find.byKey(const Key('modal.save')));
          await tester.pumpAndSettle();

          await tester.enterText(find.byKey(const Key('catalog.name')), 'new-name');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();
          await tester.pumpAndSettle();

          // reset catalog name
          final w = find.byKey(const Key('catalog.c-1')).evaluate().first.widget;
          expect(((w as ListTile).title as Text).data, equals('new-name'));
          expect(catalog1.imagePath, equals(newImage));

          verify(storage.set(
            any,
            argThat(equals({
              'c-1.name': 'new-name',
              'c-1.imagePath': newImage,
            })),
          ));
        });

        testWidgets('Reorder catalog', (WidgetTester tester) async {
          deviceAs(device, tester);
          final catalog1 = Catalog(name: 'c-1', id: 'c-1', index: 1);
          final catalog2 = Catalog(name: 'c-2', id: 'c-2', index: 2);
          final catalog3 = Catalog(name: 'c-3', id: 'c-3', index: 3);
          Menu().replaceItems({'c-1': catalog1, 'c-2': catalog2, 'c-3': catalog3});

          await tester.pumpWidget(MultiProvider(providers: [
            ChangeNotifierProvider<Menu>.value(value: Menu.instance),
          ], child: buildApp()));

          await tester.tap(find.byIcon(KIcons.reorder));
          await tester.pumpAndSettle();

          await tester.drag(find.byIcon(Icons.reorder_outlined).first, const Offset(0, 150));

          await tester.tap(find.byKey(const Key('reorder.save')));
          await tester.pumpAndSettle();

          final y1 = tester.getCenter(find.byKey(const Key('catalog.c-1'))).dy;
          final y2 = tester.getCenter(find.byKey(const Key('catalog.c-2'))).dy;
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
          deviceAs(device, tester);
          final productImage = await createImage('product');
          final catalogImage = await createImage('catalog');
          final catalog1 = Catalog(id: 'c-1');
          final catalog2 = Catalog(id: 'c-2', imagePath: catalogImage, products: {
            'p-1': Product(id: 'p-1', imagePath: productImage),
          });
          Menu().replaceItems({'c-1': catalog1, 'c-2': catalog2});
          await createImage('product-avator');
          await createImage('catalog-avator');

          await tester.pumpWidget(MultiProvider(providers: [
            ChangeNotifierProvider<Menu>.value(value: Menu.instance),
          ], child: buildApp()));

          await tester.longPress(find.byKey(const Key('catalog.c-1')));
          await tester.pumpAndSettle();
          await tester.tap(find.byIcon(KIcons.delete));
          await tester.pumpAndSettle();

          await tester.tap(find.byKey(const Key('delete_dialog.confirm')));
          await tester.pumpAndSettle();

          expect(find.byKey(const Key('catalog.c-1')), findsNothing);
          verify(storage.set(any, argThat(equals({catalog1.prefix: null}))));

          await tester.longPress(find.byKey(const Key('catalog.c-2')));
          await (device == Device.mobile ? tester.pumpAndSettle() : tester.pump(const Duration(milliseconds: 500)));
          await tester.tap(find.byIcon(KIcons.delete));
          await tester.pumpAndSettle();

          await tester.tap(find.byKey(const Key('delete_dialog.confirm')));
          await tester.pumpAndSettle();

          expect(find.byKey(const Key('catalog.c-2')), findsNothing);
          expect(Menu.instance.isEmpty, isTrue);
          verify(storage.set(any, argThat(equals({catalog2.prefix: null}))));
        });
      });
    }

    testWidgets('Navigate to catalog', (WidgetTester tester) async {
      Menu().replaceItems({'c-1': Catalog(id: 'c-1', name: 'c-1')});

      await tester.pumpWidget(MultiProvider(providers: [
        ChangeNotifierProvider<Menu>.value(value: Menu.instance),
        ChangeNotifierProvider<Stock>.value(value: Stock()),
      ], child: buildApp()));

      await tester.tap(find.byKey(const Key('catalog.c-1')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('catalog.empty')), findsOneWidget);
    });

    testWidgets('Search product', (WidgetTester tester) async {
      final now = DateTime.now();
      final product = Product(id: 'p-1', name: 'p-1', searchedAt: now, ingredients: {
        'pi-1': ProductIngredient(id: 'pi-1', ingredient: Ingredient(id: 'i-1', name: 'i-1'), quantities: {
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
        child: buildApp(),
      ));
      await tester.tap(find.byKey(const Key('menu.search')));
      await tester.pumpAndSettle();

      // product 2 has older searchedAt value
      final y1 = tester.getCenter(find.byKey(const Key('search.p-1'))).dy;
      final y2 = tester.getCenter(find.byKey(const Key('search.p-2'))).dy;
      expect(y1, greaterThan(y2));

      // enter non-matched products
      await tester.enterText(find.byType(TextField).last, 'empty');
      await tester.pumpAndSettle();

      expect(find.text(S.menuSearchNotFound), findsOneWidget);

      // enter match products (including ingredient)
      await tester.enterText(find.byType(TextField).last, '2');
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('search.p-1')), findsOneWidget);
      expect(find.byKey(const Key('search.p-2')), findsOneWidget);

      // should match specific quantity
      await tester.enterText(find.byType(TextField).last, 'q-1');
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('search.p-1')), findsOneWidget);
      expect(find.byKey(const Key('search.p-2')), findsNothing);

      // navigate to product
      await tester.tap(find.byKey(const Key('search.p-1')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('product_ingredient.pi-1')), findsOneWidget);
      expect(find.byKey(const Key('product_ingredient.pi-2')), findsOneWidget);

      // should update searchedAt
      verify(storage.set(any, argThat(predicate((data) {
        return data is Map && data['${product.prefix}.searchedAt'] > 0;
      }))));
    });

    testWidgets('Pop back to catalog list', (WidgetTester tester) async {
      Menu().replaceItems({'c-1': Catalog(id: 'c-1', name: 'c-1')});
      OrderAttributes();

      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<Menu>.value(value: Menu.instance),
          ChangeNotifierProvider<OrderAttributes>.value(value: OrderAttributes.instance),
          ChangeNotifierProvider.value(value: Printers()),
        ],
        child: MaterialApp.router(
          theme: AppThemes.lightTheme,
          routerConfig: GoRouter(navigatorKey: Routes.rootNavigatorKey, routes: [
            GoRoute(
              path: '/',
              builder: (context, __) => TextButton(
                onPressed: () => context.goNamed(
                  Routes.menu,
                  queryParameters: {'id': 'c-1'},
                ),
                child: const Text('go'),
              ),
            ),
            ...Routes.getDesiredRoute(0).routes,
          ]),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('pop')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('catalog.c-1')), findsOneWidget);
    });

    setUp(() async {
      await cache.reset();
      when(cache.get(any)).thenReturn(true);
    });

    setUpAll(() {
      initializeStorage();
      initializeCache();
      initializeTranslator();
      initializeFileSystem();
    });

    tearDown(() => reset(storage));
  });
}
