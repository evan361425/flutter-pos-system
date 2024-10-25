import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/models/stock/replenishment.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/stock/stock_view.dart';
import 'package:provider/provider.dart';

import '../../mocks/mock_cache.dart';
import '../../mocks/mock_storage.dart';
import '../../test_helpers/translator.dart';

void main() {
  group('Stock View', () {
    Widget buildApp() {
      return MaterialApp.router(
        routerConfig: GoRouter(navigatorKey: Routes.rootNavigatorKey, routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const Scaffold(body: StockView()),
          ),
          ...Routes.getDesiredRoute(0).routes,
        ]),
      );
    }

    testWidgets('add ingredient', (tester) async {
      final stock = Stock()..replaceItems({});
      await tester.pumpWidget(MultiProvider(providers: [
        ChangeNotifierProvider<Stock>.value(value: stock),
        ChangeNotifierProvider<Replenisher>.value(value: Replenisher()..replaceItems({})),
        ChangeNotifierProvider<Menu>.value(value: Menu()..replaceItems({})),
      ], child: buildApp()));
      await tester.tap(find.byKey(const Key('empty_body')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('stock.ingredient.amount')), '1');
      await tester.enterText(find.byKey(const Key('stock.ingredient.name')), 'i-1');
      await tester.enterText(find.byKey(const Key('stock.ingredient.totalAmount')), '50');
      await tester.tap(find.byKey(const Key('modal.save')));
      // wait for updating
      await tester.pumpAndSettle();
      // wait for pop
      await tester.pumpAndSettle();

      expect(stock.length, equals(1));
      expect(stock.items.first.name, equals('i-1'));
      expect(stock.items.first.currentAmount, equals(1));
      expect(stock.items.first.totalAmount, equals(50));
    });

    testWidgets('replenishment apply successfully', (tester) async {
      final replenishment = Replenishment(id: 'r-1', data: {
        'i-1': 10,
        'i-2': -5,
      });
      final ing1 = Ingredient(
        id: 'i-1',
        name: 'i-1',
        updatedAt: DateTime(2020, 10, 10),
      );
      final ing2 = Ingredient(
        id: 'i-2',
        name: 'i-2',
        currentAmount: 4,
        updatedAt: DateTime(2020, 10, 11),
      );
      final stock = Stock()..replaceItems({'i-1': ing1, 'i-2': ing2});
      final repl = Replenisher()..replaceItems({'r-1': replenishment});

      await tester.pumpWidget(MultiProvider(providers: [
        ChangeNotifierProvider<Stock>.value(value: stock),
        ChangeNotifierProvider<Replenisher>.value(value: repl),
      ], child: buildApp()));

      void verifyLastUpdated(DateTime dt) {
        final s = S.stockUpdatedAt(dt);
        expect(find.text('$s${MetaBlock.string}${S.totalCount(2)}'), findsOneWidget);
      }

      verifyLastUpdated(DateTime(2020, 10, 11));

      await tester.tap(find.byKey(const Key('stock.replenisher')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('replenisher.r-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('repl.apply')));
      await tester.pumpAndSettle();

      expect(ing1.currentAmount, equals(10));
      expect(ing1.lastAmount, equals(10));
      expect(ing2.currentAmount, equals(0));

      verifyLastUpdated(DateTime.now());
    });

    Future<void> buildAppWithIngredients([WidgetTester? tester]) async {
      final ingredient = Ingredient(id: 'i-1', name: 'i-1');
      final stock = Stock()
        ..replaceItems({
          'i-1': ingredient,
          'i-2': Ingredient(id: 'i-2', name: 'i-2'),
        });
      final catalog = Catalog(id: 'c-1', products: {
        'p-1': Product(id: 'p-1', ingredients: {
          'pi-1': ProductIngredient(id: 'pi-1', ingredient: ingredient),
        }),
      });
      final menu = Menu()..replaceItems({'c-1': catalog});
      final quantities = Quantities()..replaceItems({});

      for (var pro in catalog.items) {
        pro.catalog = catalog;
        for (var ing in pro.items) {
          ing.product = pro;
        }
      }
      when(storage.set(any, any)).thenAnswer((_) => Future.value());
      if (tester == null) return;

      await tester.pumpWidget(MultiProvider(providers: [
        ChangeNotifierProvider<Stock>.value(value: stock),
        ChangeNotifierProvider<Menu>.value(value: menu),
        ChangeNotifierProvider<Quantities>.value(value: quantities),
      ], child: buildApp()));
    }

    testWidgets('edit amount by quantity', (tester) async {
      await buildAppWithIngredients();
      Stock.instance.getItem('i-1')!.totalAmount = 54321;
      Stock.instance.getItem('i-2')!.lastAmount = 900.56;
      await tester.pumpWidget(MultiProvider(providers: [
        ChangeNotifierProvider<Stock>.value(value: Stock.instance),
        ChangeNotifierProvider<Menu>.value(value: Menu.instance),
        ChangeNotifierProvider<Quantities>.value(value: Quantities.instance),
      ], child: buildApp()));

      // correctly transform string
      expect(find.text('0／${54321.toCurrency()}'), findsOneWidget);
      expect(find.text('0／901'), findsOneWidget);

      final ingredient = Stock.instance.items.first;

      // tap and text
      await tester.tap(find.byKey(const Key('stock.i-1')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('slider_dialog.text')), '10');
      await tester.tap(find.byKey(const Key('slider_dialog.confirm')));
      await tester.pumpAndSettle();
      expect(ingredient.currentAmount, equals(10));

      await tester.longPress(find.byKey(const Key('stock.i-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.edit_square));
      await tester.pumpAndSettle();

      final w = find.byKey(const Key('slider_dialog.text')).evaluate().single.widget as TextFormField;
      expect(w.controller!.text, equals('10'));

      await tester.tap(find.byType(Slider));
      expect(w.controller!.text, equals('27161'));

      await tester.tap(find.byKey(const Key('slider_dialog.confirm')));
      await tester.pumpAndSettle();
      expect(ingredient.currentAmount, equals(27161));
    });

    testWidgets('edit amount by price', (tester) async {
      await buildAppWithIngredients();
      final ing = Stock.instance.getItem('i-2')!;
      ing.currentAmount = 1;
      ing.restockPrice = 2;
      ing.restockQuantity = 3;
      ing.restockLastPrice = 4;
      when(cache.set('stock.replenishBy', 1)).thenAnswer((_) => Future.value(true));

      await tester.pumpWidget(MultiProvider(providers: [
        ChangeNotifierProvider<Stock>.value(value: Stock.instance),
        ChangeNotifierProvider<Menu>.value(value: Menu.instance),
        ChangeNotifierProvider<Quantities>.value(value: Quantities.instance),
      ], child: buildApp()));

      await tester.tap(find.byKey(const Key('stock.i-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('stock.repl.switch')));
      await tester.pumpAndSettle();
      verify(cache.set('stock.replenishBy', 1));

      await tester.tap(find.byKey(const Key('slider_dialog.confirm')));
      await tester.pumpAndSettle();

      when(cache.get('stock.replenishBy')).thenReturn(1);
      await tester.tap(find.byKey(const Key('stock.i-2')));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(KIcons.edit).last);
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('stock.ing_restock.price')), '1.1');
      await tester.enterText(find.byKey(const Key('stock.ing_restock.quantity')), '2.2');
      await tester.tap(find.byKey(const Key('modal.save')));
      await tester.pumpAndSettle();

      final tf = find.byKey(const Key('stock.repl.price.text')).evaluate().single.widget as TextFormField;
      expect(tf.controller!.text, equals('4'));

      await tester.enterText(find.byKey(const Key('stock.repl.price.text')), 'abc');
      await tester.pumpAndSettle();
      expect(find.text('1'), findsNWidgets(2)); // original value

      await tester.enterText(find.byKey(const Key('stock.repl.price.text')), '6.6');
      await tester.pumpAndSettle();
      expect(find.text('14.20'), findsOneWidget); // 6.6 / 1.1 * 2.2 + 1

      await tester.tap(find.byKey(const Key('slider_dialog.confirm')));
      await tester.pumpAndSettle();

      expect(ing.currentAmount, equals(14.2));
      expect(ing.restockLastPrice, equals(6.6));
      verifyNever(cache.set('stock.replenishBy', any));
    });

    testWidgets('edit ingredient', (tester) async {
      await buildAppWithIngredients(tester);
      Stock.instance.getItem('i-1')!.totalAmount = 500;

      // go to ingredient modal
      await tester.tap(find.byKey(const Key('stock.i-1.edit')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('stock.ingredient.amount')), '1');
      await tester.enterText(find.byKey(const Key('stock.ingredient.totalAmount')), '');

      // go to product
      final p1 = find.byKey(const Key('stock.ingredient.p-1'));
      await tester.dragUntilVisible(p1, find.byType(ListView), const Offset(0, -300));
      await tester.tap(p1);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('pop')).last);
      await tester.pumpAndSettle();

      // validate failed
      await tester.enterText(find.byKey(const Key('stock.ingredient.name')), 'i-2');
      await tester.tap(find.byKey(const Key('modal.save')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('stock.ingredient.name')), 'i-3');
      await tester.tap(find.byKey(const Key('modal.save')));
      // wait for updating
      await tester.pumpAndSettle();
      // wait for pop
      await tester.pumpAndSettle();

      // check name is changed
      final w = find.byKey(const Key('stock.i-1'));
      expect(w, findsOneWidget);
      expect(((w.evaluate().first.widget as ListTile).title as Text).data, equals('i-3'));

      final ingredient = Stock.instance.items.first;
      expect(ingredient.name, equals('i-3'));
      expect(ingredient.currentAmount, equals(1));
      expect(ingredient.totalAmount, isNull);
      expect(ingredient.restockPrice, isNull);
      expect(ingredient.restockQuantity, equals(1));
    });

    testWidgets('delete ingredient', (tester) async {
      await buildAppWithIngredients(tester);

      deleteIngredient(String id) async {
        await tester.longPress(find.byKey(Key('stock.$id')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('btn.delete')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('delete_dialog.confirm')));
        await tester.pumpAndSettle();
      }

      await deleteIngredient('i-1');
      expect(Stock.instance.length, equals(1));
      // product's ingredient should also deleted
      expect(Menu.instance.items.first.items.first.length, isZero);

      await deleteIngredient('i-2');
      expect(Stock.instance.length, isZero);
    });

    setUp(() {
      when(cache.get(any)).thenReturn(null);
      // disable tutorial
      when(cache.get(
        argThat(predicate<String>((key) => key.startsWith('tutorial.'))),
      )).thenReturn(true);
    });

    setUpAll(() {
      initializeStorage();
      initializeCache();
      initializeTranslator();
    });
  });
}
