import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/constants/icons.dart';
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
import 'package:possystem/ui/stock/stock_screen.dart';
import 'package:provider/provider.dart';

import '../../mocks/mock_cache.dart';
import '../../mocks/mock_storage.dart';
import '../../test_helpers/translator.dart';

void main() {
  group('Stock Screen', () {
    Widget buildApp() {
      return MaterialApp(
        routes: Routes.routes,
        home: const Scaffold(body: StockScreen()),
      );
    }

    testWidgets('add ingredient', (tester) async {
      final stock = Stock()..replaceItems({});
      await tester.pumpWidget(MultiProvider(providers: [
        ChangeNotifierProvider<Stock>.value(value: stock),
        ChangeNotifierProvider<Replenisher>.value(
            value: Replenisher()..replaceItems({})),
        ChangeNotifierProvider<Menu>.value(value: Menu()..replaceItems({})),
      ], child: buildApp()));
      await tester.tap(find.byKey(const Key('empty_body')));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('stock.ingredient.amount')), '1');
      await tester.enterText(
          find.byKey(const Key('stock.ingredient.name')), 'i-1');
      await tester.enterText(
          find.byKey(const Key('stock.ingredient.totalAmount')), '50');
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
        expect(find.text('$s${MetaBlock.string}總共 2 項'), findsOneWidget);
      }

      verifyLastUpdated(DateTime(2020, 10, 11));

      await tester.tap(find.byKey(const Key('stock.replenisher')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('replenisher.r-1.apply')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm_dialog.confirm')));
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

    testWidgets('edit amount of ingredient', (tester) async {
      await buildAppWithIngredients();
      Stock.instance.getItem('i-1')!.totalAmount = 54321;
      Stock.instance.getItem('i-2')!.lastAmount = 900.56;
      await tester.pumpWidget(MultiProvider(providers: [
        ChangeNotifierProvider<Stock>.value(value: Stock.instance),
        ChangeNotifierProvider<Menu>.value(value: Menu.instance),
        ChangeNotifierProvider<Quantities>.value(value: Quantities.instance),
      ], child: buildApp()));

      tapAndEnter(String key, String text) async {
        await tester.tap(find.byKey(Key(key)));
        await tester.pumpAndSettle();
        await tester.enterText(
            find.byKey(const Key('slider_dialog.text')), text);
        await tester.tap(find.byKey(const Key('slider_dialog.confirm')));
        await tester.pumpAndSettle();
      }

      // correctly transform string
      expect(find.text('5.4e+4'), findsOneWidget);
      expect(find.text('900.6'), findsOneWidget);

      final ingredient = Stock.instance.items.first;

      await tapAndEnter('stock.i-1', '10');
      expect(ingredient.currentAmount, equals(10));

      await tester.tap(find.byKey(const Key('stock.i-1')));
      await tester.pumpAndSettle();

      final w = find
          .byKey(const Key('slider_dialog.text'))
          .evaluate()
          .single
          .widget as TextFormField;
      expect(w.controller!.text, equals('10.0'));

      await tester.tap(find.byType(Slider));
      expect(w.controller!.text, equals('27161'));

      await tester.tap(find.byKey(const Key('slider_dialog.confirm')));
      await tester.pumpAndSettle();
      expect(ingredient.currentAmount, equals(27161));
    });

    testWidgets('edit ingredient', (tester) async {
      await buildAppWithIngredients(tester);
      Stock.instance.getItem('i-1')!.totalAmount = 500;

      // go to ingredient modal
      await tester.tap(find.byKey(const Key('stock.i-1.edit')));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('stock.ingredient.amount')), '1');
      await tester.enterText(
          find.byKey(const Key('stock.ingredient.totalAmount')), '');

      // go to product
      await tester.tap(find.byKey(const Key('stock.ingredient.p-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(KIcons.back));
      await tester.pumpAndSettle();

      // validate failed
      await tester.enterText(
          find.byKey(const Key('stock.ingredient.name')), 'i-2');
      await tester.tap(find.byKey(const Key('modal.save')));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('stock.ingredient.name')), 'i-3');
      await tester.tap(find.byKey(const Key('modal.save')));
      // wait for updating
      await tester.pumpAndSettle();
      // wait for pop
      await tester.pumpAndSettle();

      // check name is changed
      final w = find.byKey(const Key('stock.i-1'));
      expect(w, findsOneWidget);
      expect(((w.evaluate().first.widget as ListTile).title as Text).data,
          equals('i-3'));

      final ingredient = Stock.instance.items.first;
      expect(ingredient.name, equals('i-3'));
      expect(ingredient.currentAmount, equals(1));
      expect(ingredient.totalAmount, isNull);
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
