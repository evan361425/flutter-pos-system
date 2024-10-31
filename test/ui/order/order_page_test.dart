import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/outlined_text.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/order/cart_product.dart';
import 'package:possystem/models/printer.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/settings/checkout_warning.dart';
import 'package:possystem/settings/order_awakening_setting.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/order/order_page.dart';
import 'package:provider/provider.dart';

import '../../mocks/mock_cache.dart';
import '../../mocks/mock_storage.dart';
import '../../test_helpers/breakpoint_mocker.dart';
import '../../test_helpers/translator.dart';

void main() {
  group('Order Page', () {
    void prepareData() {
      Printers();
      Stock().replaceItems({
        'i-1': Ingredient(id: 'i-1', name: 'i-1'),
        'i-2': Ingredient(id: 'i-2', name: 'i-2'),
        'i-3': Ingredient(id: 'i-3', name: 'i-3'),
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
        quantities: {
          'pq-3': ProductQuantity(
            id: 'pq-3',
            quantity: Quantities.instance.getItem('q-2'),
            amount: -5,
            additionalCost: -5,
            additionalPrice: -10,
          ),
        },
      );
      final ingredient3 = ProductIngredient(
        id: 'pi-3',
        ingredient: Stock.instance.getItem('i-3'),
        amount: 1,
      );
      final product1 = Product(id: 'p-1', name: 'p-1', price: 17, ingredients: {
        'pi-1': ingredient1..prepareItem(),
        'pi-2': ingredient2..prepareItem(),
      });
      final product2 = Product(id: 'p-2', name: 'p-2', price: 11);
      final product3 = Product(id: 'p-3', name: 'p-3', price: 0, ingredients: {
        'pi-3': ingredient3,
      });
      Menu().replaceItems({
        'c-1': Catalog(
          id: 'c-1',
          name: 'c-1',
          index: 1,
          products: {'p-1': product1..prepareItem(), 'p-3': product3},
        )..prepareItem(),
        'c-2': Catalog(
          name: 'c-2',
          id: 'c-2',
          index: 2,
          products: {'p-2': product2},
        )..prepareItem(),
      });

      // setup model
      Cart.instance = Cart();
    }

    Widget buildApp<T>({T Function()? popResult}) {
      final baseRoute = Routes.getDesiredRoute(0).routes[0] as GoRoute;
      return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: Seller.instance),
          ChangeNotifierProvider.value(value: Cart.instance),
        ],
        child: MaterialApp.router(
          routerConfig: GoRouter(navigatorKey: Routes.rootNavigatorKey, routes: [
            GoRoute(
              path: '/',
              builder: (_, __) => const OrderPage(),
              routes: [
                GoRoute(
                  name: Routes.orderCheckout,
                  path: 'test',
                  builder: (context, __) {
                    return Scaffold(
                      body: TextButton(
                        onPressed: () => context.pop(popResult?.call()),
                        child: const Text('hi', key: Key('test')),
                      ),
                    );
                  },
                ),
              ],
            ),
            GoRoute(
              path: baseRoute.path,
              redirect: baseRoute.redirect,
              routes: baseRoute.routes.where((e) => e is! GoRoute || e.name != Routes.order).toList(),
            ),
          ]),
        ),
      );
    }

    group('Draggable Sheet', () {
      testWidgets('Selecting change state', (tester) async {
        await tester.pumpWidget(buildApp(
          popResult: () => CheckoutStatus.nothingHappened,
        ));

        await tester.tap(find.byKey(const Key('order.product.p-1')));
        await tester.tap(find.byKey(const Key('order.catalog.c-2')));
        await tester.pumpAndSettle();
        // cancel tap
        final gesture = await tester.startGesture(tester.getRect(find.byKey(const Key('order.product.p-2'))).center);
        await tester.pump(const Duration(milliseconds: 100));
        await gesture.moveBy(const Offset(0.0, 200.0));
        await gesture.cancel();
        // normal tap
        await tester.tap(find.byKey(const Key('order.product.p-2')));
        await tester.pumpAndSettle();
        // swipe left and right
        await tester.drag(
          find.byKey(const Key('order.product.p-2')),
          const Offset(500.0, 0.0),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('order.product.p-1')), findsOneWidget);
        await tester.drag(
          find.byKey(const Key('order.product.p-1')),
          const Offset(-500.0, 0.0),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('order.product.p-2')), findsOneWidget);

        // go ordering

        verifySnapshot(List<List<String>> data, num price) {
          var count = 0;
          for (var item in data) {
            final w = tester.widget<OutlinedText>(find.byKey(Key('cart_snapshot.${count++}')));
            expect(w.text, equals(item[0]));
            expect(w.badge, equals(item[1]));
          }
          final w = tester.widget<Text>(find.byKey(const Key('cart_snapshot.price')));
          expect(w.data, equals(price.toString()));
        }

        verifyProductList(
          int index, {
          String? title,
          String? subtitle,
          bool? selected,
          int? count,
          num? price,
        }) {
          final key = 'cart.product.$index';
          final w = tester.widget<ListTile>(find.byKey(Key(key)));
          if (title != null) {
            expect((w.title as Text).data, equals(title));
          }
          if (subtitle != null) {
            subtitle.isEmpty
                ? expect(w.subtitle, isA<HintText>())
                : expect((w.subtitle as RichText).text.toPlainText(), equals(subtitle));
          }
          if (selected != null) {
            expect(w.selected, equals(selected));
          }
          if (count != null) {
            expect(tester.widget<Text>(find.byKey(Key('$key.count'))).data, equals(count.toString()));
          }
          if (price != null) {
            expect(tester.widget<Text>(find.byKey(Key('$key.price'))).data,
                equals(S.orderCartProductPrice(price.toCurrency())));
          }
        }

        verifyMetadata(int count, num price) {
          final w = tester.widget<Expanded>(find.byKey(const Key('cart.metadata')));
          final t =
              '${S.orderCartMetaTotalCount(count)}${MetaBlock.string}${S.orderCartMetaTotalPrice(price.toCurrency())}';
          expect((w.child as RichText).text.toPlainText(), equals(t));
        }

        verifySnapshot([
          ['p-1', '1'],
          ['p-2', '1'],
        ], 28);

        await tester.drag(
          find.byKey(const Key('order.ds')),
          // should below the window height: H - currentH < 300
          const Offset(0, -300),
        );
        await tester.pumpAndSettle();

        verifyProductList(0, title: 'p-1', selected: false);
        verifyProductList(1, title: 'p-2', selected: true);
        verifyMetadata(2, 28);

        expect(find.byKey(const Key('order.ingredient.noNeedIngredient')), findsOneWidget);

        // full screen the panel
        await tester.dragFrom(
          tester.getCenter(find.byKey(const Key('cart.product_list'))),
          const Offset(0, -200),
        );
        await tester.pumpAndSettle();

        // select product
        await tester.tap(find.byKey(const Key('cart.product.0')));
        await tester.pumpAndSettle();

        verifyProductList(0, selected: true);
        verifyProductList(1, selected: false);

        // select quantity
        await tester.tap(find.byKey(const Key('order.quantity.pq-1')));
        await tester.pumpAndSettle();
        verifyProductList(0, subtitle: S.orderCartProductIngredient('i-1', 'q-1'), price: 27);

        await tester.tap(find.byKey(const Key('order.quantity.default')));
        await tester.pumpAndSettle();
        verifyProductList(0, subtitle: '', price: 17);

        await tester.tap(find.byKey(const Key('order.quantity.pq-2')));
        await tester.pumpAndSettle();
        verifyProductList(0, subtitle: S.orderCartProductIngredient('i-1', 'q-2'), price: 7);

        // add count
        await tester.tap(find.byKey(const Key('cart.product.0.add')));
        await tester.tap(find.byKey(const Key('cart.product.1.add')));
        await tester.pumpAndSettle();
        verifyProductList(0, selected: true, price: 14, count: 2);
        verifyProductList(1, selected: false, price: 22, count: 2);
        verifyMetadata(4, 36);

        // select by checkbox
        await tester.tap(find.byKey(const Key('cart.product.1.select')));
        await tester.pumpAndSettle();
        verifyProductList(0, selected: true);
        verifyProductList(1, selected: true);
        expect(find.byKey(const Key('order.ingredient.differentProducts')), findsOneWidget);

        await tester.tap(find.byKey(const Key('cart.product.1.select')));
        await tester.pumpAndSettle();
        verifyProductList(0, selected: true);
        verifyProductList(1, selected: false);
        expect(tester.widget<ChoiceChip>(find.byKey(const Key('order.quantity.pq-2'))).selected, isTrue);

        // select ingredient
        await tester.tap(find.byKey(const Key('order.ingredient.pi-2')));
        await tester.pumpAndSettle();
        expect(tester.widget<ChoiceChip>(find.byKey(const Key('order.quantity.default'))).selected, isTrue);

        // select all, toggle all
        await tester.tap(find.byKey(const Key('cart.toggle_all')));
        await tester.pumpAndSettle();
        verifyProductList(0, selected: false);
        verifyProductList(1, selected: true);
        await tester.tap(find.byKey(const Key('cart.select_all')));
        await tester.pumpAndSettle();
        verifyProductList(0, selected: true);
        verifyProductList(1, selected: true);

        // close panel and verify snapshot state
        await tester.drag(
          find.byKey(const Key('order.ds')),
          const Offset(0, 300),
        );
        await tester.pumpAndSettle();
        final bg = tester.getTopLeft(find.byKey(const Key('order.bg')));
        await tester.tapAt(bg.translate(1, 1));
        await tester.pumpAndSettle();

        verifySnapshot([
          ['p-1', '2'],
          ['p-2', '2'],
        ], 36);

        // open by tapping snapshot product
        await tester.tap(find.byKey(const Key('cart_snapshot.0')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('order.ingredient.pi-2')), findsOneWidget);
      });
    });

    group('All in one page', () {
      testWidgets('scroll to bottom', (tester) async {
        OrderAwakeningSetting.instance.value = false;
        deviceAs(Device.landscape, tester);

        try {
          prepareData();

          await tester.pumpWidget(buildApp());

          // check open and close is all ok
          await tester.tap(find.byIcon(Icons.grid_view_outlined));
          await tester.pumpAndSettle();
          expect(find.byIcon(Icons.view_list_outlined), findsOneWidget);
          await tester.tap(find.byIcon(Icons.grid_view_outlined).first);
          await tester.pumpAndSettle();
          expect(find.byIcon(Icons.view_list_outlined), findsNothing);
          // change the view
          await tester.tap(find.byIcon(Icons.grid_view_outlined));
          await tester.pumpAndSettle();
          await tester.tap(find.byIcon(Icons.view_list_outlined));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const Key('order.product.p-1')));
          await tester.tap(find.byKey(const Key('order.catalog.c-2')));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const Key('order.product.p-2')));
          await tester.tap(find.byKey(const Key('order.product.p-2')));
          await tester.tap(find.byKey(const Key('order.product.p-2')));
          await tester.tap(find.byKey(const Key('order.product.p-2')));
          await tester.tap(find.byKey(const Key('order.product.p-2')));
          await tester.tap(find.byKey(const Key('order.product.p-2')));
          await tester.tap(find.byKey(const Key('order.product.p-2')));
          await tester.tap(find.byKey(const Key('order.product.p-2')));
          await tester.tap(find.byKey(const Key('order.product.p-2')));
          await tester.tap(find.byKey(const Key('order.product.p-2')));
          await tester.tap(find.byKey(const Key('order.product.p-2')));
          await tester.tap(find.byKey(const Key('order.product.p-2')));
          await tester.pumpAndSettle();

          expect(find.byKey(const Key('cart_snapshot.price')), findsNothing);
          final scrollController = tester.widget<ListView>(find.byKey(const Key('cart.product_list'))).controller!;
          // scroll to bottom
          expect(scrollController.position.maxScrollExtent, isNonZero);

          // setup portrait env
          deviceAs(Device.mobile, tester);

          // change the view should not happen any error
          await tester.pumpAndSettle();
        } finally {
          OrderAwakeningSetting.instance.value = OrderAwakeningSetting.defaultValue;
        }
      });
    });

    testWidgets('Cart actions', (tester) async {
      deviceAs(Device.mobile, tester);
      Cart.instance.replaceAll(products: [
        CartProduct(Menu.instance.getProduct('p-1')!, count: 1),
        CartProduct(Menu.instance.getProduct('p-1')!, count: 8),
        CartProduct(Menu.instance.getProduct('p-2')!, isSelected: true),
      ]);

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.drag(
        find.byKey(const Key('order.ds')),
        const Offset(0, -800),
      );
      await tester.pumpAndSettle();

      // remove it
      await tester.drag(
        find.byKey(const Key('cart.product.0')),
        const Offset(-1200, 0),
      );
      await tester.pumpAndSettle();

      // after remove, selection should not be changed.
      expect(find.byKey(const Key('cart.product.2')), findsNothing);
      expect(Cart.instance.selected.first.id, equals('p-2'));

      tapAction(String action, {int? product, String? text}) async {
        if (product == null) {
          await tester.tap(find.byKey(const Key('cart.action')));
          await tester.pumpAndSettle();
        } else {
          await tester.longPress(find.byKey(Key('cart.product.$product')));
          await tester.pumpAndSettle();
          await tester.pump(const Duration(seconds: 1));
        }

        await tester.tap(find.byKey(Key('cart.action.$action')));
        await tester.pumpAndSettle();

        if (text != null) {
          await tester.enterText(find.byType(TextFormField), text);
          await tester.tap(find.byKey(const Key('text_dialog.confirm')));
          await tester.pumpAndSettle();
        }
      }

      verifyProductList(int index, {int? count, num? price}) {
        final key = 'cart.product.$index';
        if (count != null) {
          expect(tester.widget<Text>(find.byKey(Key('$key.count'))).data, equals(count.toString()));
        }
        if (price != null) {
          expect(tester.widget<Text>(find.byKey(Key('$key.price'))).data,
              equals(S.orderCartProductPrice(price.toCurrency())));
        }
      }

      verifyMetadata(int count, num price) {
        final w = tester.widget<Expanded>(find.byKey(const Key('cart.metadata')));
        final t =
            '${S.orderCartMetaTotalCount(count)}${MetaBlock.string}${S.orderCartMetaTotalPrice(price.toCurrency())}';
        expect((w.child as RichText).text.toPlainText(), equals(t));
      }

      await tapAction('count', text: '20');
      verifyProductList(0, count: 8, price: 17 * 8);
      verifyProductList(1, count: 20, price: 11 * 20);
      verifyMetadata(28, 17 * 8 + 11 * 20);

      await tapAction('price', product: 0, text: '30');
      verifyProductList(0, count: 8, price: 30 * 8);
      verifyProductList(1, count: 20, price: 11 * 20);
      verifyMetadata(28, 30 * 8 + 11 * 20);

      await tester.tap(find.byKey(const Key('cart.product.1.select')));
      await tester.pumpAndSettle();

      // discount will use original price, 17 -> 9, 11 -> 6
      await tapAction('discount', text: '50');
      verifyProductList(0, count: 8, price: 9 * 8);
      verifyProductList(1, count: 20, price: 6 * 20);
      verifyMetadata(28, 9 * 8 + 6 * 20);

      await tapAction('free');
      verifyProductList(0, count: 8, price: 0);
      verifyProductList(1, count: 20, price: 0);
      verifyMetadata(28, 0);

      await tapAction('delete', product: 1);
      verifyProductList(0, count: 8, price: 0);
      expect(find.byKey(const Key('cart.product.1')), findsNothing);
      verifyMetadata(8, 0);
    });

    testWidgets('Ingredient should selected by product', (tester) async {
      deviceAs(Device.mobile, tester);
      await tester.pumpWidget(buildApp());

      await tester.tap(find.byKey(const Key('order.product.p-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('order.product.p-3')));
      await tester.pumpAndSettle();

      await tester.drag(find.byKey(const Key('order.ds')), const Offset(0, -1200));
      await tester.pumpAndSettle();
      await tester.dragFrom(const Offset(0, 400), const Offset(0, -300));
      await tester.pumpAndSettle();

      final chip = tester.widget<ChoiceChip>(find.byKey(const Key('order.ingredient.pi-3')));
      expect(chip.selected, isTrue);

      await tester.tap(find.byKey(const Key('cart.product.1.select')));
      await tester.pumpAndSettle();

      expect(find.text(S.orderCartIngredientStatus('differentProducts')), findsOneWidget);
    });

    testWidgets('Show different message by cashier status', (tester) async {
      late CheckoutStatus status;
      OrderAttributes();

      await tester.pumpWidget(buildApp(popResult: () => status));
      Future<void> tapWithCheck(
        CheckoutStatus value, [
        String? expectValue,
      ]) async {
        status = value;
        await tester.tap(find.byKey(const Key('order.checkout')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('test')));
        await tester.pumpAndSettle();

        if (expectValue != null) {
          expect(find.text(expectValue), findsOneWidget);
        }
      }

      // hide all
      CheckoutWarningSetting.instance.value = CheckoutWarningTypes.hideAll;
      await tapWithCheck(CheckoutStatus.ok, S.actSuccess);
      await tapWithCheck(CheckoutStatus.restore, S.actSuccess);
      await tapWithCheck(CheckoutStatus.stash, S.actSuccess);
      await tapWithCheck(
        CheckoutStatus.fromCashier(CashierUpdateStatus.notEnough),
        S.actSuccess,
      );
      await tapWithCheck(
        CheckoutStatus.fromCashier(CashierUpdateStatus.usingSmall),
        S.actSuccess,
      );
      await tapWithCheck(CheckoutStatus.nothingHappened);

      // only not enough
      CheckoutWarningSetting.instance.value = CheckoutWarningTypes.onlyNotEnough;
      await tapWithCheck(CheckoutStatus.cashierNotEnough, S.orderSnackbarCashierNotEnough);
      await tapWithCheck(CheckoutStatus.cashierUsingSmall, S.actSuccess);

      // show all
      CheckoutWarningSetting.instance.value = CheckoutWarningTypes.showAll;
      await tapWithCheck(CheckoutStatus.cashierUsingSmall, S.orderSnackbarCashierUsingSmallMoney);
    });

    setUp(() {
      cache.reset();
      // disable any features
      when(cache.get(any)).thenReturn(null);
      // disable tutorial
      when(cache.get(
        argThat(predicate<String>((key) => key.startsWith('tutorial.'))),
      )).thenReturn(true);

      prepareData();
      Cashier().setCurrent(null);
    });

    setUpAll(() {
      initializeCache();
      initializeStorage();
      initializeTranslator();
    });
  });
}
