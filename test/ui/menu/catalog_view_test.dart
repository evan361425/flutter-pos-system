import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/xfile.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/menu/menu_page.dart';
import 'package:provider/provider.dart';

import '../../mocks/mock_storage.dart';
import '../../test_helpers/file_mocker.dart';
import '../../test_helpers/translator.dart';

void main() {
  Widget buildApp({String? popImage}) {
    final baseRoute = Routes.getDesiredRoute(0).routes[0] as GoRoute;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Stock>.value(value: Stock()),
        ChangeNotifierProvider<Quantities>.value(value: Quantities()),
        ChangeNotifierProvider<Menu>.value(value: Menu.instance)
      ],
      child: MaterialApp.router(
        routerConfig: GoRouter(navigatorKey: Routes.rootNavigatorKey, routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const MenuPage(),
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
      ),
    );
  }

  Future<void> moveTo(WidgetTester tester, Catalog catalog) async {
    await tester.tap(find.byKey(Key('catalog.${catalog.id}')));
    await tester.pumpAndSettle();
  }

  group('Catalog View', () {
    testWidgets('Add product', (WidgetTester tester) async {
      final catalog = Catalog(id: 'c-1', imagePath: 'some-non-exist');
      Menu().replaceItems({'c-1': catalog});

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await moveTo(tester, catalog);

      await tester.tap(find.byKey(const Key('empty_body')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('product.name')), 'name');
      await tester.enterText(find.byKey(const Key('product.price')), '1');
      await tester.enterText(find.byKey(const Key('product.cost')), '1');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // navigate to product screen
      expect(find.byKey(const Key('menu.add_product')), findsOneWidget);

      final product = catalog.items.first;
      expect(product.name, equals('name'));
      expect(product.index, equals(1));
      expect(product.cost, equals(1));
      expect(product.price, equals(1));

      verify(storage.set(any, argThat(predicate((data) {
        final map = (data as Map).values.first;
        return map is Map && map['price'] == 1 && map['cost'] == 1 && map['name'] == 'name' && map['index'] == 1;
      }))));
    });

    testWidgets('Navigate to product', (WidgetTester tester) async {
      final catalog = Catalog(id: 'c-1', name: 'c-1', products: {
        'p-1': Product(id: 'p-1', name: 'p-1'),
      });
      Menu().replaceItems({'c-1': catalog..prepareItem()});

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await moveTo(tester, catalog);

      await tester.tap(find.byKey(const Key('product.p-1')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('menu.add_product')), findsOneWidget);
    });

    testWidgets('Edit product', (WidgetTester tester) async {
      final oldImage = await createImage('old');
      final oldAvator = await createImage('old-avator');
      final newImage = await createImage('test-image');
      final product = Product(id: 'p-1', name: 'p-1', imagePath: oldImage);
      final catalog = Catalog(id: 'c-1', name: 'c-1', products: {
        'p-1': product,
        'p-2': Product(id: 'p-2', name: 'p-2'),
      });
      Menu().replaceItems({'c-1': catalog..prepareItem()});

      await tester.pumpWidget(buildApp(popImage: newImage));
      await tester.pumpAndSettle();

      await moveTo(tester, catalog);

      await tester.longPress(find.byKey(const Key('product.p-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(KIcons.modal));
      await tester.pumpAndSettle();

      // save failed
      await tester.enterText(find.byKey(const Key('product.name')), 'p-2');
      await tester.tap(find.byKey(const Key('modal.save')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('image_holder.edit')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('tap me'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('product.name')), 'new-name');
      await tester.enterText(find.byKey(const Key('product.price')), '1');
      await tester.enterText(find.byKey(const Key('product.cost')), '1');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // reset product name
      final w = find.byKey(const Key('product.p-1')).evaluate().first.widget;
      expect(((w as ListTile).title as Text).data, equals('new-name'));
      expect(product.cost, equals(1));
      expect(product.price, equals(1));
      expect(product.imagePath, newImage);

      final prefix = product.prefix;
      verify(storage.set(any, argThat(predicate((data) {
        return data is Map &&
            data['$prefix.price'] == 1 &&
            data['$prefix.cost'] == 1 &&
            data['$prefix.name'] == 'new-name' &&
            data['$prefix.imagePath'] == newImage;
      }))));
      expect(XFile(oldImage).file.existsSync(), isTrue);
      expect(XFile(oldAvator).file.existsSync(), isTrue);
    });

    testWidgets('Reorder product', (WidgetTester tester) async {
      final p1 = Product(id: 'p-1', name: 'p-1', index: 1);
      final p2 = Product(id: 'p-2', name: 'p-2', index: 2);
      final catalog = Catalog(id: 'c-1', products: {
        'p-1': p1,
        'p-2': p2,
        'p-3': Product(id: 'p-3', name: 'p-3', index: 3),
      });
      Menu().replaceItems({'c-1': catalog..prepareItem()});

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await moveTo(tester, catalog);

      await tester.tap(find.byIcon(KIcons.reorder));
      await tester.pumpAndSettle();

      await tester.drag(find.byIcon(Icons.reorder_outlined).first, const Offset(0, 150));

      await tester.tap(find.byKey(const Key('reorder.save')));
      await tester.pumpAndSettle();

      final y1 = tester.getCenter(find.byKey(const Key('product.p-1'))).dy;
      final y2 = tester.getCenter(find.byKey(const Key('product.p-2'))).dy;
      final itemList = catalog.itemList;
      expect(y1, greaterThan(y2));
      expect(itemList[0].id, equals('p-2'));
      expect(itemList[1].id, equals('p-1'));
      expect(itemList[2].id, equals('p-3'));

      verify(storage.set(
        any,
        argThat(equals({'${p1.prefix}.index': 2, '${p2.prefix}.index': 1})),
      ));
    });

    testWidgets('Delete product', (WidgetTester tester) async {
      final product = Product(id: 'p-1');
      final catalog = Catalog(id: 'c-1', name: 'c-1', products: {
        'p-1': product,
      });
      Menu().replaceItems({'c-1': catalog..prepareItem()});

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await moveTo(tester, catalog);

      await tester.longPress(find.byKey(const Key('product.p-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(KIcons.delete));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('delete_dialog.confirm')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('product.p-1')), findsNothing);
      expect(catalog.isEmpty, isTrue);
      verify(storage.set(any, argThat(equals({product.prefix: null}))));
    });

    setUpAll(() {
      initializeStorage();
      initializeTranslator();
    });

    setUp(() {
      initializeFileSystem();
    });
  });
}
