import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/xfile.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/menu/catalog/catalog_screen.dart';
import 'package:provider/provider.dart';

import '../../test_helpers/file_mocker.dart';
import '../../mocks/mock_storage.dart';
import '../../test_helpers/translator.dart';

void main() {
  Map<String, Widget Function(BuildContext)> popImageRoutes(String path) {
    return {
      ...Routes.routes,
      Routes.imageGallery: (BuildContext context) {
        return TextButton(
          onPressed: () => Navigator.of(context).pop(path),
          child: const Text('tap me'),
        );
      }
    };
  }

  group('Catalog Screen', () {
    testWidgets('Add product', (WidgetTester tester) async {
      final catalog = Catalog(id: 'c-1', imagePath: 'some-non-exist');
      Menu().replaceItems({'c-1': catalog});

      await tester.pumpWidget(MultiProvider(
          providers: [
            ChangeNotifierProvider<Catalog>.value(value: catalog),
            ChangeNotifierProvider<Stock>.value(value: Stock()),
            ChangeNotifierProvider<Quantities>.value(value: Quantities()),
          ],
          child:
              MaterialApp(routes: Routes.routes, home: const CatalogScreen())));
      await tester.pumpAndSettle();

      verify(storage.set(any, argThat(predicate((data) {
        return data is Map && data.values.first == null;
      }))));

      await tester.tap(find.byKey(const Key('empty_body')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('product.name')), 'name');
      await tester.enterText(find.byKey(const Key('product.price')), '1');
      await tester.enterText(find.byKey(const Key('product.cost')), '1');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // navigate to product screen
      expect(find.byKey(const Key('product.add')), findsOneWidget);

      final product = catalog.items.first;
      expect(product.name, equals('name'));
      expect(product.index, equals(1));
      expect(product.cost, equals(1));
      expect(product.price, equals(1));

      verify(storage.set(any, argThat(predicate((data) {
        final map = (data as Map).values.first;
        return map is Map &&
            map['price'] == 1 &&
            map['cost'] == 1 &&
            map['name'] == 'name' &&
            map['index'] == 1;
      }))));
    });

    testWidgets('Navigate to product', (WidgetTester tester) async {
      final catalog = Catalog(id: 'c-1', name: 'c-1', products: {
        'p-1': Product(id: 'p-1', name: 'p-1'),
      });
      Menu().replaceItems({'c-1': catalog..prepareItem()});

      await tester.pumpWidget(MultiProvider(
          providers: [
            ChangeNotifierProvider<Catalog>.value(value: catalog),
            ChangeNotifierProvider<Stock>.value(value: Stock()),
            ChangeNotifierProvider<Quantities>.value(value: Quantities()),
          ],
          child:
              MaterialApp(routes: Routes.routes, home: const CatalogScreen())));

      await tester.tap(find.byKey(const Key('product.p-1')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('product.add')), findsOneWidget);
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

      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<Catalog>.value(value: catalog),
          ChangeNotifierProvider<Stock>.value(value: Stock()),
        ],
        child: MaterialApp(
          routes: popImageRoutes(newImage),
          home: const CatalogScreen(),
        ),
      ));

      await tester.longPress(find.byKey(const Key('product.p-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.text_fields_sharp));
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

      await tester.pumpWidget(MultiProvider(
          providers: [
            ChangeNotifierProvider<Catalog>.value(value: catalog),
            ChangeNotifierProvider<Stock>.value(value: Stock()),
          ],
          child:
              MaterialApp(routes: Routes.routes, home: const CatalogScreen())));

      await tester.tap(find.byIcon(KIcons.more));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.reorder_sharp));
      await tester.pumpAndSettle();

      await tester.drag(
          find.byIcon(Icons.reorder_sharp).first, const Offset(0, 150));

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

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<Stock>.value(value: Stock()),
            ChangeNotifierProvider<Catalog>.value(value: catalog),
          ],
          child: MaterialApp(
            routes: Routes.routes,
            home: const CatalogScreen(),
          ),
        ),
      );

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

    testWidgets('Update image', (WidgetTester tester) async {
      final newImage = await createImage('test-image');
      final catalog = Catalog(id: 'c');
      Menu().replaceItems({'c': catalog});

      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<Stock>.value(value: Stock()),
          ChangeNotifierProvider<Catalog>.value(value: catalog),
        ],
        child: MaterialApp(
          routes: popImageRoutes(newImage),
          home: const CatalogScreen(),
        ),
      ));

      await tester.tap(find.byKey(const Key('item_more_action')));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.image_sharp));
      await tester.pumpAndSettle();
      await tester.tap(find.text('tap me'));
      await tester.pumpAndSettle();

      verify(storage.set(any, argThat(predicate((data) {
        return data is Map && data['c.imagePath'] == newImage;
      }))));
      expect(catalog.imagePath, equals(newImage));
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
