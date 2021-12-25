import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
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
import 'package:possystem/ui/stock/stock_screen.dart';
import 'package:provider/provider.dart';

import '../../mocks/mock_cache.dart';
import '../../mocks/mock_storage.dart';
import '../../test_helpers/disable_tips.dart';
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
      await tester.tap(find.byKey(const Key('modal.save')));
      // wait for updating
      await tester.pumpAndSettle();
      // wait for pop
      await tester.pumpAndSettle();

      expect(stock.length, equals(1));
      expect(stock.items.first.name, equals('i-1'));
      expect(stock.items.first.currentAmount, equals(1));
    });

    testWidgets('replenishment apply successfully', (tester) async {
      final replenishment = Replenishment(id: 'r-1', data: {
        'i-1': 10,
        'i-2': -5,
      });
      final ing1 = Ingredient(id: 'i-1', name: 'i-1');
      final ing2 = Ingredient(id: 'i-2', name: 'i-2', currentAmount: 4);
      final stock = Stock()..replaceItems({'i-1': ing1, 'i-2': ing2});
      final repli = Replenisher()..replaceItems({'r-1': replenishment});

      await tester.pumpWidget(MultiProvider(providers: [
        ChangeNotifierProvider<Stock>.value(value: stock),
        ChangeNotifierProvider<Replenisher>.value(value: repli),
      ], child: buildApp()));

      await tester.tap(find.byKey(const Key('stock.replenisher')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('replenisher.r-1.apply')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm_dialog.confirm')));
      await tester.pumpAndSettle();

      expect(ing1.currentAmount, equals(10));
      expect(ing1.lastAddAmount, equals(10));
      expect(ing1.lastAmount, equals(10));
      expect(ing2.currentAmount, equals(0));
    });

    Future<void> buildAppWithIngredients(WidgetTester tester) async {
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

      await tester.pumpWidget(MultiProvider(providers: [
        ChangeNotifierProvider<Stock>.value(value: stock),
        ChangeNotifierProvider<Menu>.value(value: menu),
        ChangeNotifierProvider<Quantities>.value(value: quantities),
      ], child: buildApp()));
    }

    testWidgets('edit amount of ingredient', (tester) async {
      await buildAppWithIngredients(tester);

      tapAndEnter(String key, String text) async {
        await tester.tap(find.byKey(Key(key)));
        await tester.pumpAndSettle();
        await tester.enterText(find.byKey(const Key('text_dialog.text')), text);
        await tester.tap(find.byKey(const Key('text_dialog.confirm')));
        await tester.pumpAndSettle();
      }

      final ingredient = Stock.instance.items.first;
      await tapAndEnter('stock.i-1.plus', '10');
      expect(ingredient.currentAmount, equals(10));
      expect(ingredient.lastAddAmount, equals(10));
      expect(ingredient.lastAmount, equals(10));

      await tapAndEnter('stock.i-1.minus', '4');
      expect(ingredient.currentAmount, equals(6));
      expect(ingredient.lastAddAmount, equals(10));
      expect(ingredient.lastAmount, equals(10));
    });

    testWidgets('edit ingredient', (tester) async {
      await buildAppWithIngredients(tester);
      // go to ingredient modal
      await tester.tap(find.byKey(const Key('stock.i-1')));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('stock.ingredient.amount')), '1');

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
      final w = find.byKey(const Key('stock.i-1')).evaluate().first.widget;
      expect(((w as ListTile).title as Text).data, equals('i-3'));

      final ingredient = Stock.instance.items.first;
      expect(ingredient.name, equals('i-3'));
      expect(ingredient.currentAmount, equals(1));
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
      when(cache.get(any)).thenReturn(1);
    });

    setUpAll(() {
      disableTips();
      initializeStorage();
      initializeCache();
      initializeTranslator();
    });
  });
}
