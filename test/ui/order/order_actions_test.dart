import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/order/cart_product.dart';
import 'package:possystem/models/order/order_attribute.dart';
import 'package:possystem/models/order/order_attribute_option.dart';
import 'package:possystem/models/printer.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/stashed_orders.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/order/order_page.dart';
import 'package:provider/provider.dart';

import '../../mocks/mock_cache.dart';
import '../../mocks/mock_database.dart';
import '../../mocks/mock_storage.dart';
import '../../test_helpers/translator.dart';

void main() {
  group('Order Actions', () {
    void prepareData() {
      Printers();
      Stock().replaceItems({
        'i-1': Ingredient(id: 'i-1', name: 'i-1'),
        'i-2': Ingredient(id: 'i-2', name: 'i-2'),
      });
      Quantities().replaceItems({'q-1': Quantity(id: 'q-1', name: 'q-1'), 'q-2': Quantity(id: 'q-2', name: 'q-2')});
      final ingredient1 = ProductIngredient(
        id: 'pi-1',
        ingredient: Stock.instance.getItem('i-1'),
        amount: 5,
        quantities: {
          'pq-1': ProductQuantity(
            id: 'pq-1',
            quantity: Quantities.instance.getItem('q-1'),
            amount: 5,
            additionalCost: 5,
            additionalPrice: 10,
          ),
          'pq-2': ProductQuantity(
            id: 'pq-2',
            quantity: Quantities.instance.getItem('q-2'),
            amount: -5,
            additionalCost: -5,
            additionalPrice: -10,
          ),
        },
      );
      final ingredient2 = ProductIngredient(
        id: 'pi-2',
        ingredient: Stock.instance.getItem('i-2'),
        amount: 3,
      );
      final product = Product(id: 'p-1', name: 'p-1', price: 17, ingredients: {
        'pi-1': ingredient1..prepareItem(),
        'pi-2': ingredient2..prepareItem(),
      });
      Menu().replaceItems({
        'c-1': Catalog(
          id: 'c-1',
          name: 'c-1',
          index: 1,
          products: {'p-1': product..prepareItem()},
        )..prepareItem(),
        'c-2': Catalog(
          name: 'c-2',
          id: 'c-2',
          index: 2,
          products: {'p-2': Product(id: 'p-2', name: 'p-2', price: 11)},
        )..prepareItem(),
      });

      OrderAttributes().replaceItems({
        for (var i = 1; i < 3; i++)
          'oa-$i': OrderAttribute(
            id: 'oa-$i',
            name: 'oa-$i',
            options: {
              'oao-$i': OrderAttributeOption(id: 'oao-$i', name: 'oao-$i'),
            },
          )..prepareItem()
      });

      Cart.instance = Cart();
      Cart.instance.replaceAll(products: [
        CartProduct(
          Menu.instance.getProduct('p-1')!,
          quantities: {'pi-1': 'pq-1', 'wrong-1': 'a-1'},
        ),
        CartProduct(Menu.instance.getProduct('p-2')!),
      ], attributes: {
        'oa-1': 'oao-1',
        'oa-2': 'oao-2'
      });
    }

    Widget buildApp<T>() {
      return ChangeNotifierProvider.value(
        value: Cart.instance,
        child: MaterialApp.router(
          routerConfig: GoRouter(navigatorKey: Routes.rootNavigatorKey, routes: [
            GoRoute(
              path: '/',
              builder: (_, __) => const OrderPage(),
            ),
            ...Routes.getDesiredRoute(0).routes,
          ]),
        ),
      );
    }

    testWidgets('Stash', (tester) async {
      final now = DateTime.now();
      final order = OrderObject(
        createdAt: now,
        products: const [
          OrderProductObject(
            productId: "p-1",
            count: 1,
            singlePrice: 17,
            ingredients: [
              OrderIngredientObject(
                productIngredientId: "pi-1",
                productQuantityId: "pq-1",
              ),
            ],
          ),
          OrderProductObject(
            productId: "p-2",
            count: 1,
            singlePrice: 11,
          ),
        ],
        attributes: const [
          OrderSelectedAttributeObject(attributeId: 'oa-1', optionId: 'oao-1'),
          OrderSelectedAttributeObject(attributeId: 'oa-2', optionId: 'oao-2'),
        ],
      );
      Cart.timer = () => now;

      await tester.pumpWidget(buildApp());

      when(database.push(any, any)).thenAnswer((_) => Future.value(1));

      await tester.tap(find.byKey(const Key('order.more')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('order.action.stash')));
      await tester.pumpAndSettle();

      expect(Cart.instance.isEmpty, isTrue);

      // empty cart will not trigger stash which will verify later.
      await tester.tap(find.byKey(const Key('order.more')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('order.action.stash')));
      await tester.pumpAndSettle();

      verify(database.push(
        StashedOrders.table,
        argThat(equals(order.toStashMap())),
      )).called(1);
    });

    testWidgets('Changer', (tester) async {
      final app = ChangeNotifierProvider.value(
        value: Cashier(),
        child: buildApp(),
      );

      when(storage.get(any, any)).thenAnswer((_) => Future.value({
            'current': [
              {'unit': 1, 'count': 0},
              {'unit': 5, 'count': 1}
            ],
            'favorites': [
              {
                'source': {'unit': 5, 'count': 1},
                'targets': [
                  {'unit': 1, 'count': 5},
                ],
              },
            ]
          }));
      await Cashier.instance.reset();

      await tester.pumpWidget(app);

      await tester.tap(find.byKey(const Key('order.more')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('order.action.exchange')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('changer.favorite.0')));
      await tester.tap(find.byKey(const Key('changer.apply')));
      await tester.pumpAndSettle();

      // should go back
      expect(find.byKey(const Key('order.more')), findsOneWidget);
      expect(Cashier.instance.at(0).count, equals(5));
      expect(Cashier.instance.at(1).count, isZero);
    });

    setUp(() {
      // disable any features
      when(cache.get(any)).thenReturn(null);
      // disable tutorial
      when(cache.get(
        argThat(predicate<String>((key) => key.startsWith('tutorial.'))),
      )).thenReturn(true);

      prepareData();
    });

    setUpAll(() {
      initializeCache();
      initializeDatabase();
      initializeStorage();
      initializeTranslator();
    });
  });
}
