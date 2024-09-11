import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
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
import 'package:possystem/models/xfile.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/menu/product_page.dart';
import 'package:provider/provider.dart';

import '../../mocks/mock_storage.dart';
import '../../test_helpers/breakpoint_mocker.dart';
import '../../test_helpers/file_mocker.dart';
import '../../test_helpers/translator.dart';

void main() {
  Widget buildApp(Product product, {String? popImage, WidgetBuilder? home}) {
    final baseRoute = Routes.getDesiredRoute(0).routes[0] as GoRoute;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Stock>.value(value: Stock.instance),
        ChangeNotifierProvider<Quantities>.value(value: Quantities.instance),
      ],
      child: MaterialApp.router(
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.dark,
        routerConfig: GoRouter(navigatorKey: Routes.rootNavigatorKey, routes: [
          GoRoute(
            path: '/',
            builder: (context, __) => home?.call(context) ?? ProductPage(product: product),
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

  group('Product Page', () {
    for (final device in [Device.desktop, Device.mobile]) {
      group(device.name, () {
        testWidgets('Edit image', (WidgetTester tester) async {
          deviceAs(device, tester);
          final newImage = await createImage('test-image');
          final product = Product(id: 'p-1', imagePath: 'wrong-path');
          final catalog = Catalog(id: 'c-1', name: 'c-1', products: {
            'p-1': product,
          })
            ..prepareItem();
          Menu().replaceItems({'c': catalog});
          Stock();
          Quantities();

          await tester.pumpWidget(buildApp(product, popImage: newImage));

          await tester.tap(find.byKey(const Key('product.more')));
          await tester.pumpAndSettle();
          await tester.tap(find.byIcon(Icons.image_outlined));
          await tester.pumpAndSettle();
          await tester.tap(find.text('tap me'));
          await tester.pumpAndSettle();

          // wait to failed loading image
          await tester.pump(const Duration(milliseconds: 500));
          final captured = verify(storage.set(any, captureAny)).captured;
          expect(captured.length, equals(2));
          expect(
            captured[0],
            predicate((data) => data is Map && data['c-1.products.p-1.imagePath'] == null),
          );
          expect(
            captured[1],
            predicate((data) => data is Map && data['c-1.products.p-1.imagePath'] == newImage),
          );

          expect(product.imagePath, equals(newImage));
        });

        testWidgets('Reorder Ingredients', (WidgetTester tester) async {
          deviceAs(device, tester);
          Stock().replaceItems({
            'p-1': Ingredient(id: 'p-1', name: 'p-1'),
            'p-2': Ingredient(id: 'p-2', name: 'p-2'),
            'p-3': Ingredient(id: 'p-3', name: 'p-3'),
          });
          Quantities();
          final p1 = ProductIngredient(id: 'p-1', name: 'p-1', index: 1, ingredient: Stock.instance.getItem('p-1'));
          final p2 = ProductIngredient(id: 'p-2', name: 'p-2', index: 2, ingredient: Stock.instance.getItem('p-2'));
          final p = Product(id: 'p', name: 'p', ingredients: {
            'p-1': p1,
            'p-2': p2,
            'p-3': ProductIngredient(id: 'p-3', name: 'p-3', index: 3, ingredient: Stock.instance.getItem('p-3')),
          });
          final catalog = Catalog(id: 'c', products: {'p': p..prepareItem()})..prepareItem();
          Menu().replaceItems({'c': catalog});

          await tester.pumpWidget(buildApp(p));
          await tester.pumpAndSettle();

          await tester.tap(find.byKey(const Key('product.more')));
          await tester.pumpAndSettle();
          await tester.tap(find.byIcon(KIcons.reorder).last);
          await tester.pumpAndSettle();

          await tester.drag(find.byIcon(Icons.reorder_outlined).first, const Offset(0, 150));

          await tester.tap(find.byKey(const Key('reorder.save')));
          await tester.pumpAndSettle();

          final y1 = tester.getCenter(find.byKey(const Key('product_ingredient.p-1'))).dy;
          final y2 = tester.getCenter(find.byKey(const Key('product_ingredient.p-2'))).dy;
          final itemList = p.itemList;
          expect(y1, greaterThan(y2));
          expect(itemList[0].id, equals('p-2'));
          expect(itemList[1].id, equals('p-1'));
          expect(itemList[2].id, equals('p-3'));

          verify(storage.set(
            any,
            argThat(equals({'${p1.prefix}.index': 2, '${p2.prefix}.index': 1})),
          ));
        });
      });
    }

    testWidgets('Delete product', (WidgetTester tester) async {
      final imagePath = await createImage('old');
      final avatorPath = await createImage('old-avator');
      final product = Product(id: 'p-1', imagePath: imagePath);
      final catalog = Catalog(id: 'c-1', products: {'p-1': product});
      Menu().replaceItems({'c-1': catalog..prepareItem()});
      Stock();
      Quantities();

      await tester.pumpWidget(buildApp(
        product,
        home: (context) => Scaffold(
          body: TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ProductPage(product: product)),
            ),
            child: const Text('go to product'),
          ),
        ),
      ));

      await tester.tap(find.text('go to product'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(KIcons.more));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(KIcons.delete));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('delete_dialog.confirm')));
      await tester.pumpAndSettle();

      expect(find.text('go to product'), findsOneWidget);
      expect(catalog.isEmpty, isTrue);
      verify(storage.set(any, argThat(equals({product.prefix: null}))));
      expect(XFile(imagePath).file.existsSync(), isTrue);
      expect(XFile(avatorPath).file.existsSync(), isTrue);
    });

    group('Product Ingredient', () {
      testWidgets('Add', (WidgetTester tester) async {
        final product = Product(id: 'p-1');
        final catalog = Catalog(id: 'c-1', products: {'p-1': product});
        Menu().replaceItems({'c-1': catalog..prepareItem()});
        Stock();
        Quantities();

        await tester.pumpWidget(buildApp(product));

        await tester.tap(find.byKey(const Key('empty_body')));
        await tester.pumpAndSettle();

        // enter amount
        await tester.enterText(find.byKey(const Key('product_ingredient.amount')), '1');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        // error message
        expect(find.text(S.menuIngredientSearchErrorEmpty), findsOneWidget);

        // add new ingredient
        await tester.tap(find.byKey(const Key('product_ingredient.search')));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField).last, 'new-ingredient');
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('product_ingredient.add_ingredient')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('modal.save')));
        await tester.pumpAndSettle();
        await tester.pumpAndSettle();

        final ingredient = product.items.first;
        final id = ingredient.ingredient.id;
        expect(ingredient.name, equals('new-ingredient'));
        expect(ingredient.amount, equals(1));

        expect(find.byKey(Key('product_ingredient.${ingredient.id}')), findsOneWidget);

        // add ingredient
        verify(storage.add(any, argThat(equals(id)), argThat(predicate((data) {
          return data is Map && data['name'] == 'new-ingredient';
        }))));
        // add product ingredient
        verify(storage.set(any, argThat(predicate((data) {
          return data is Map &&
              data[ingredient.prefix] is Map &&
              data[ingredient.prefix]['ingredientId'] == id &&
              data[ingredient.prefix]['amount'] == 1;
        }))));
        // product ingredient id is different from ingredient id
        expect(id, isNot(equals(ingredient.id)));
      });

      void prepareData() {
        final stock = Stock()
          ..replaceItems({
            'i-1': Ingredient(id: 'i-1', name: 'i-1'),
            'i-2': Ingredient(id: 'i-2', name: 'i-2', currentAmount: 1),
            'i-3': Ingredient(id: 'i-3', name: 'prefix-i-3'),
          });
        final ingredient = ProductIngredient(
          id: 'pi-1',
          ingredient: stock.getItem('i-1'),
        );
        final product = Product(id: 'p-1', ingredients: {
          'pi-1': ingredient,
          'pi-2': ProductIngredient(id: 'pi-2', ingredient: stock.getItem('i-2')),
        });
        Menu().replaceItems({
          'c-1': Catalog(id: 'c-1', products: {'p-1': product..prepareItem()})..prepareItem()
        });
      }

      testWidgets('Edit', (WidgetTester tester) async {
        prepareData();
        Quantities();

        final product = Menu.instance.items.first.items.first;
        final ingredient = product.items.first;

        await tester.pumpWidget(buildApp(product));

        const key = 'product_ingredient.pi-1';
        await tester.tap(find.byKey(const Key(key)));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('$key.more')));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(KIcons.modal));
        await tester.pumpAndSettle();

        // search for ingredient2
        await tester.tap(find.byKey(const Key('product_ingredient.search')));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField).last, '2');
        await tester.pumpAndSettle();

        // go into modal and edit ingredient2 name
        await tester.tap(find.byIcon(Icons.open_in_new_outlined));
        await tester.pumpAndSettle();
        await tester.enterText(find.byKey(const Key('stock.ingredient.name')), 'i-2-n');
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('modal.save')).last);
        await tester.pumpAndSettle();

        // select new name
        await tester.tap(find.byKey(const Key('product_ingredient.search')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('i-2-n').last);
        await tester.pumpAndSettle();

        // enter amount
        await tester.enterText(find.byKey(const Key('product_ingredient.amount')), '1');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        // error message
        expect(find.text(S.menuIngredientSearchErrorRepeat), findsOneWidget);

        // search for ingredient3
        await tester.tap(find.byKey(const Key('product_ingredient.search')));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField).last, 'abc');
        await tester.pumpAndSettle();

        // prefix-i-3 should be smaller similarity
        await tester.enterText(find.byType(TextField).last, 'i-');
        await tester.pumpAndSettle();
        expect(tester.getCenter(find.byKey(const Key('product_ingredient.search.i-2'))).dy,
            lessThan(tester.getCenter(find.byKey(const Key('product_ingredient.search.i-3'))).dy));

        await tester.enterText(find.byType(TextField).last, '3');
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('product_ingredient.search.i-3')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('modal.save')));
        await tester.pumpAndSettle();
        await tester.pumpAndSettle();

        // reset ingredient name
        final w = find.byKey(const Key(key)).evaluate().first.widget;
        expect(((w as ExpansionTile).title as Text).data, equals('prefix-i-3'));
        expect(ingredient.amount, equals(1));

        // edit ingredient and product ingredient
        final captured = verify(storage.set(any, captureAny)).captured;
        expect(captured.length, equals(2));
        expect(captured[0],
            predicate((data) => data is Map && data['i-2.name'] == 'i-2-n' && data['i-2.updatedAt'] != null));
        expect(
            captured[1],
            predicate((data) =>
                data is Map &&
                data['${ingredient.prefix}.amount'] == 1 &&
                data['${ingredient.prefix}.ingredientId'] == 'i-3'));
      });

      testWidgets('Delete', (WidgetTester tester) async {
        prepareData();
        Quantities();
        final product = Menu.instance.items.first.items.first;
        final ingredient = product.items.first;

        await tester.pumpWidget(buildApp(product));

        await tester.tap(find.byKey(const Key('product_ingredient.pi-1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('product_ingredient.pi-1.more')));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(KIcons.delete));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('delete_dialog.confirm')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('product_ingredient.pi-1')), findsNothing);
        expect(product.getItem('pi-1'), isNull);
        verify(storage.set(any, argThat(equals({ingredient.prefix: null}))));
      });
    });

    group('Product Quantity', () {
      void prepareData() {
        final qs = Quantities()
          ..replaceItems({
            'q-1': Quantity(id: 'q-1', name: 'q-1'),
            'q-2': Quantity(id: 'q-2', name: 'q-2'),
            'q-3': Quantity(id: 'q-3', name: 'q-3'),
          });
        final stock = Stock()..replaceItems({'i-1': Ingredient(id: 'i-1', name: 'i-1')});
        final ingredient = ProductIngredient(id: 'pi-1', ingredient: stock.getItem('i-1'), quantities: {
          'pq-1': ProductQuantity(id: 'pq-1', quantity: qs.getItem('q-1')),
          'pq-2': ProductQuantity(id: 'pq-2', quantity: qs.getItem('q-2')),
        });
        final product = Product(id: 'p-1', ingredients: {'pi-1': ingredient..prepareItem()});
        final catalog = Catalog(id: 'c-1', products: {'p-1': product..prepareItem()});
        Menu().replaceItems({'c-1': catalog..prepareItem()});
      }

      testWidgets('Add', (WidgetTester tester) async {
        prepareData();
        final product = Menu.instance.items.first.items.first;

        await tester.pumpWidget(buildApp(product));

        await tester.tap(find.byKey(const Key('product_ingredient.pi-1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('product_ingredient.pi-1.add')));
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key('product_quantity.price')), '1');
        await tester.enterText(find.byKey(const Key('product_quantity.cost')), '1');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        // error message
        expect(find.text(S.menuQuantitySearchErrorEmpty), findsOneWidget);

        // add new quantity
        await tester.tap(find.byKey(const Key('product_quantity.search')));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField).last, 'new-quantity');
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('product_quantity.add_quantity')));
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key('product_quantity.amount')), '1');

        await tester.tap(find.byKey(const Key('modal.save')));
        await tester.pumpAndSettle();
        await tester.pumpAndSettle();

        final quantity = product.items.first.items.last;
        final id = quantity.quantity.id;
        expect(quantity.name, equals('new-quantity'));
        expect(quantity.amount, equals(1));
        expect(quantity.additionalCost, equals(1));
        expect(quantity.additionalPrice, equals(1));

        expect(find.byKey(Key('product_quantity.${quantity.id}')), findsOneWidget);

        // add quantity
        verify(storage.add(any, argThat(equals(id)), argThat(predicate((data) {
          return data is Map && data['name'] == 'new-quantity';
        }))));
        // add product ingredient
        verify(storage.set(any, argThat(predicate((data) {
          return data is Map &&
              data[quantity.prefix] is Map &&
              data[quantity.prefix]['quantityId'] == id &&
              data[quantity.prefix]['amount'] == 1 &&
              data[quantity.prefix]['additionalCost'] == 1 &&
              data[quantity.prefix]['additionalPrice'] == 1;
        }))));
        // product ingredient id is different from ingredient id
        expect(id, isNot(equals(quantity.id)));
      });

      testWidgets('Edit', (WidgetTester tester) async {
        prepareData();
        final product = Menu.instance.items.first.items.first;
        final quantity = product.items.first.items.first;

        await tester.pumpWidget(buildApp(product));

        await tester.tap(find.byKey(const Key('product_ingredient.pi-1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('product_quantity.pq-1')));
        await tester.pumpAndSettle();

        // search for quantity2
        await tester.tap(find.byKey(const Key('product_quantity.search')));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField).last, '2');
        await tester.pumpAndSettle();

        // go into modal and edit quantity2 name
        await tester.tap(find.byIcon(Icons.open_in_new_outlined));
        await tester.pumpAndSettle();
        await tester.enterText(find.byKey(const Key('quantity.name')), 'q-2-n');
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('modal.save')).last);
        await tester.pumpAndSettle();

        // select new name
        await tester.tap(find.byKey(const Key('product_quantity.search')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('q-2-n').last);
        await tester.pumpAndSettle();

        // edit properties
        await tester.enterText(find.byKey(const Key('product_quantity.price')), '1');
        await tester.enterText(find.byKey(const Key('product_quantity.cost')), '1');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        // error message
        expect(find.text(S.menuQuantitySearchErrorRepeat), findsOneWidget);

        // search for quantity3
        await tester.tap(find.byKey(const Key('product_quantity.search')));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField).last, '=' * 40);
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField).last, '3');
        await tester.pumpAndSettle();
        await tester.tap(find.text('q-3'));
        await tester.pumpAndSettle();

        // amount will be effect by proportion
        var w = find.byKey(const Key('product_quantity.amount')).evaluate().first;
        expect((w.widget as TextFormField).initialValue, equals('0'));

        await tester.enterText(find.byKey(const Key('product_quantity.amount')), '1');
        await tester.tap(find.byKey(const Key('modal.save')));
        await tester.pumpAndSettle();
        await tester.pumpAndSettle();

        // reset quantity name
        w = find.byKey(const Key('product_quantity.pq-1')).evaluate().first;
        expect(((w.widget as ListTile).title as Text).data, equals('q-3'));
        expect(quantity.amount, equals(1));
        expect(quantity.additionalCost, equals(1));
        expect(quantity.additionalPrice, equals(1));

        // edit ingredient and product ingredient
        final captured = verify(storage.set(any, captureAny)).captured;
        expect(captured.length, equals(2));
        expect(captured[0], predicate((data) => data is Map && data['q-2.name'] == 'q-2-n'));
        expect(
            captured[1],
            predicate((data) =>
                data is Map &&
                data['${quantity.prefix}.amount'] == 1 &&
                data['${quantity.prefix}.additionalCost'] == 1 &&
                data['${quantity.prefix}.additionalPrice'] == 1 &&
                data['${quantity.prefix}.quantityId'] == 'q-3'));
      });

      testWidgets('Delete', (WidgetTester tester) async {
        prepareData();
        final product = Menu.instance.items.first.items.first;
        final ingredient = product.items.first;
        final quantity = ingredient.items.first;

        await tester.pumpWidget(buildApp(product));

        await tester.longPress(find.byKey(const Key('product_ingredient.pi-1')));
        await tester.pumpAndSettle();
        await tester.longPress(find.byKey(const Key('product_quantity.pq-1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(KIcons.delete));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('delete_dialog.confirm')));
        await tester.pumpAndSettle();

        // expansion is still open
        expect(find.byKey(const Key('product_ingredient.pi-1.add')), findsOneWidget);
        expect(find.byKey(const Key('product_quantity.pq-1')), findsNothing);
        expect(ingredient.getItem('pq-1'), isNull);
        verify(storage.set(any, argThat(equals({quantity.prefix: null}))));
      });
    });

    setUpAll(() {
      initializeStorage();
      initializeTranslator();
      initializeFileSystem();
    });
  });
}
