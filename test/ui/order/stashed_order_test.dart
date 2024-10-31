import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/printer.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/stashed_orders.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/order/checkout/stashed_order_list_view.dart';

import '../../mocks/mock_cache.dart';
import '../../mocks/mock_database.dart';
import '../../test_helpers/order_setter.dart';
import '../../test_helpers/translator.dart';

void main() {
  group('Stashed Order', () {
    Widget buildApp() {
      return MaterialApp.router(
        routerConfig: GoRouter(initialLocation: '/test', routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const Text('Home Page'),
            routes: [
              GoRoute(
                path: 'test',
                builder: (context, state) => const Scaffold(
                  body: StashedOrderListView(),
                ),
              ),
            ],
          ),
        ]),
      );
    }

    List<OrderObject> prepareOrders({required DateTime now}) {
      Printers();
      Menu().replaceItems({
        'c-1': Catalog(id: 'c-1', name: 'c-1')
          ..replaceItems({
            'p-1': Product(id: 'p-1', name: 'p-1', price: 17, cost: 10),
            'p-2': Product(id: 'p-2', name: 'p-2', price: 666, cost: 20),
          })
          ..prepareItem(),
      });
      Stock();
      Quantities();
      Cashier();
      Cart.instance = Cart();
      Cart.timer = () => now;

      final orders = [
        OrderObject(
          id: 1,
          paid: 1349,
          price: 1349,
          cost: 50,
          productsPrice: 1349,
          productsCount: 3,
          createdAt: now,
          products: const [
            OrderProductObject(
              productId: "p-1",
              productName: 'p-1',
              catalogName: 'c-1',
              count: 1,
              singlePrice: 17,
              originalPrice: 17,
              singleCost: 10,
              isDiscount: false,
              ingredients: [
                OrderIngredientObject(
                  productIngredientId: 'i-1',
                  productQuantityId: 'q-1',
                ),
                OrderIngredientObject(
                  productIngredientId: 'i-2',
                  productQuantityId: null,
                ),
              ],
            ),
            OrderProductObject(
              productId: "p-2",
              productName: "p-2",
              catalogName: 'c-1',
              count: 2,
              singlePrice: 666,
              originalPrice: 666,
              singleCost: 20,
              isDiscount: false,
            ),
            OrderProductObject(
              productId: "p-3",
              count: 2,
              singlePrice: 666,
            ),
          ],
          attributes: const [
            OrderSelectedAttributeObject(attributeId: 'a-1', optionId: 'ao-1'),
          ],
        )
      ];

      when(database.query(
        any,
        orderBy: 'createdAt desc',
        limit: 10,
        offset: 0,
      )).thenAnswer(
        (_) => Future.value(orders.mapIndexed((i, e) {
          final m = e.toStashMap();
          m['id'] = i;
          return m;
        }).toList()),
      );

      when(database.query(
        any,
        columns: argThat(equals(['COUNT(*) count']), named: 'columns'),
      )).thenAnswer(
        (_) => Future.value([
          {'count': orders.length}
        ]),
      );

      when(database.delete(any, any)).thenAnswer((inv) {
        orders.removeAt(inv.positionalArguments[1] as int);
        return Future.value();
      });

      return orders;
    }

    testWidgets('delete should reload the page', (tester) async {
      prepareOrders(now: DateTime.now());

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      final order = find.byKey(const Key('stashed_order.0'));
      await tester.longPress(order);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('btn.delete')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('delete_dialog.confirm')));
      await tester.pumpAndSettle();

      expect(order, findsNothing);
    });

    testWidgets('drag to recover', (tester) async {
      final now = DateTime.now();
      final orders = prepareOrders(now: now);

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.drag(
        find.byKey(const Key('stashed_order.0')),
        const Offset(-1200, 0),
      );
      await tester.pumpAndSettle();

      // should pop
      expect(find.text('Home Page'), findsOneWidget);

      // been deleted
      expect(orders.isEmpty, isTrue);

      // been replaced
      final product = Cart.instance.products[0];
      expect(product.id, equals('p-1'));
    });

    testWidgets('recover should pop', (tester) async {
      final now = DateTime.now();
      final orders = prepareOrders(now: now.subtract(const Duration(days: 2)));

      // should confirm later to test overwriting.
      Cart.instance.add(Product(id: 'p-0', name: 'p-0'));

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.longPress(find.byKey(const Key('stashed_order.0')));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.file_upload_outlined));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('confirm_dialog.confirm')));
      await tester.pumpAndSettle();

      // should pop
      expect(find.text('Home Page'), findsOneWidget);

      // been deleted
      expect(orders.isEmpty, isTrue);

      // been replaced
      final product = Cart.instance.products[0];
      expect(product.id, equals('p-1'));
    });

    testWidgets('checkout will failed if paid not enough', (tester) async {
      prepareOrders(now: DateTime.now());

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('stashed_order.0')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('cashier.calculator.1')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('cashier.calculator.submit')));
      await tester.pumpAndSettle();

      expect(find.text(S.orderCheckoutSnackbarPaidFailed), findsOneWidget);
    });

    testWidgets('checkout will delete order after success', (tester) async {
      final now = DateTime.now();
      Cart.timer = () => now;
      final order = prepareOrders(now: now)[0];
      // ignore verify ingredients has pushed
      OrderSetter.setPushed(order);

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('stashed_order.0')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('cashier.calculator.submit')));
      await tester.pumpAndSettle();

      final latest = await StashedOrders.instance.getItems();
      expect(latest.isEmpty, isTrue);
    });

    setUp(() {
      when(cache.get(any)).thenReturn(null);
    });

    setUpAll(() {
      initializeCache();
      initializeDatabase();
      initializeTranslator();
      OrderAttributes();
    });
  });
}
