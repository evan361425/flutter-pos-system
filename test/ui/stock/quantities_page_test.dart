import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/stock/quantities_page.dart';
import 'package:provider/provider.dart';

import '../../mocks/mock_storage.dart';
import '../../test_helpers/translator.dart';

void main() {
  group('Quantity Page', () {
    Widget buildApp() {
      return MaterialApp.router(
        routerConfig: GoRouter(navigatorKey: Routes.rootNavigatorKey, routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const Scaffold(body: QuantitiesPage()),
          ),
          ...Routes.getDesiredRoute(0).routes,
        ]),
      );
    }

    testWidgets('Edit quantity', (tester) async {
      final quantity = Quantity(id: 'q-1', name: 'q-1');
      final quantities = Quantities()
        ..replaceItems({
          'q-1': quantity,
          'q-2': Quantity(id: 'q-2', name: 'q-2'),
        });
      when(storage.set(any, any)).thenAnswer((_) => Future.value());

      await tester.pumpWidget(ChangeNotifierProvider<Quantities>.value(
        value: quantities,
        builder: (_, __) => buildApp(),
      ));

      await tester.tap(find.byKey(const Key('quantities.q-1')));
      await tester.pumpAndSettle();

      // should failed
      await tester.enterText(find.byKey(const Key('quantity.name')), 'q-2');
      await tester.tap(find.byKey(const Key('modal.save')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('quantity.name')), 'q-3');
      await tester.enterText(find.byKey(const Key('quantity.proportion')), '2');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      // update to storage
      await tester.pumpAndSettle();
      // pop
      await tester.pumpAndSettle();

      final w = find.byKey(const Key('quantities.q-1')).evaluate().first.widget;
      expect(((w as ListTile).title as Text).data, equals('q-3'));
      expect(quantity.defaultProportion, equals(2));
    });

    testWidgets('Add quantity', (tester) async {
      final quantities = Quantities()..replaceItems({});
      when(storage.set(any, any)).thenAnswer((_) => Future.value());

      await tester.pumpWidget(ChangeNotifierProvider<Quantities>.value(
        value: quantities,
        builder: (_, __) => buildApp(),
      ));

      await tester.tap(find.byKey(const Key('empty_body')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('quantity.name')), 'q-1');
      await tester.enterText(find.byKey(const Key('quantity.proportion')), '2');
      await tester.tap(find.byKey(const Key('modal.save')));
      // save to storage
      await tester.pumpAndSettle();
      // pop
      await tester.pumpAndSettle();

      final quantity = quantities.items.first;
      final w = find.byKey(Key('quantities.${quantity.id}')).evaluate().first.widget;

      expect(((w as ListTile).title as Text).data, equals('q-1'));
      expect(quantity.defaultProportion, equals(2));
    });

    testWidgets('Delete quantity', (tester) async {
      final quantity = Quantity(id: 'q-1', name: 'q-1');
      final quantities = Quantities()
        ..replaceItems({
          'q-1': quantity,
          'q-2': Quantity(id: 'q-2', name: 'q-2'),
        });
      final pIng = ProductIngredient(
        id: 'pi-1',
        ingredient: Ingredient(id: 'i-1', name: 'i-1'),
        quantities: {
          'pq-1': ProductQuantity(id: 'pq-1', quantity: quantity),
        },
      );
      final catalog = Catalog(id: 'c-1', products: {
        'p-1': Product(id: 'p-1', ingredients: {'pi-1': pIng}),
      });
      final menu = Menu()..replaceItems({'c-1': catalog});
      for (var pro in catalog.items) {
        pro.catalog = catalog;
        for (var ing in pro.items) {
          ing.product = pro;
          for (var qua in ing.items) {
            qua.ingredient = ing;
          }
        }
      }
      when(storage.set(any, any)).thenAnswer((_) => Future.value());

      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<Menu>.value(value: menu),
          ChangeNotifierProvider<Quantities>.value(value: quantities),
        ],
        builder: (_, __) => buildApp(),
      ));

      deleteQuantity(String id) async {
        await tester.longPress(find.byKey(Key('quantities.$id')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('btn.delete')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('delete_dialog.confirm')));
        await tester.pumpAndSettle();
      }

      expect(pIng.length, isNonZero);

      await deleteQuantity('q-1');

      expect(find.byKey(const Key('quantities.q-1')), findsNothing);
      expect(Quantities.instance.length, equals(1));
      // product ingredient's quantity should also deleted
      expect(pIng.length, isZero);

      await deleteQuantity('q-2');
      expect(Quantities.instance.length, isZero);
    });

    setUpAll(() {
      initializeStorage();
      initializeTranslator();
    });
  });
}
