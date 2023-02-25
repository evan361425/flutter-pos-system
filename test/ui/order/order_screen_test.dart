import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/outlined_text.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/order/order_product.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/settings/cashier_warning.dart';
import 'package:possystem/settings/settings_provider.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/order/order_screen.dart';
import 'package:provider/provider.dart';

import '../../mocks/mock_cache.dart';
import '../../mocks/mock_storage.dart';
import '../../test_helpers/translator.dart';

void main() {
  group('Order Screen', () {
    void prepareData() {
      SettingsProvider(SettingsProvider.allSettings);

      Stock().replaceItems({
        'i-1': Ingredient(id: 'i-1', name: 'i-1'),
        'i-2': Ingredient(id: 'i-2', name: 'i-2'),
        'i-3': Ingredient(id: 'i-3', name: 'i-3'),
      });
      Quantities().replaceItems({
        'q-1': Quantity(id: 'q-1', name: 'q-1'),
        'q-2': Quantity(id: 'q-2', name: 'q-2')
      });
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
      Seller();
      Cart.instance = Cart();
    }

    Widget orderScreenWidget([Key? key]) {
      return ChangeNotifierProvider.value(
        value: Seller(),
        child: OrderScreen(key: key),
      );
    }

    group('Slidable Panel', () {
      testWidgets('Selecting change state', (tester) async {
        final key = GlobalKey<OrderScreenState>();
        await tester.pumpWidget(MaterialApp(home: orderScreenWidget(key)));

        await tester.tap(find.byKey(const Key('order.product.p-1')));
        await tester.tap(find.byKey(const Key('order.catalog.c-2')));
        await tester.pumpAndSettle();
        // cancel tap
        final gesture = await tester.startGesture(
            tester.getRect(find.byKey(const Key('order.product.p-2'))).center);
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
            final w = tester.widget<OutlinedText>(
                find.byKey(Key('cart_snapshot.${count++}')));
            expect(w.text, equals(item[0]));
            expect(w.badge, equals(item[1]));
          }
          final w =
              tester.widget<Text>(find.byKey(const Key('cart_snapshot.price')));
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
                ? expect(w.subtitle, isNull)
                : expect((w.subtitle as RichText).text.toPlainText(),
                    equals(subtitle));
          }
          if (selected != null) {
            expect(w.selected, equals(selected));
          }
          if (count != null) {
            expect(tester.widget<Text>(find.byKey(Key('$key.count'))).data,
                equals(count.toString()));
          }
          if (price != null) {
            expect(tester.widget<Text>(find.byKey(Key('$key.price'))).data,
                equals(S.orderCartItemPrice(price.toInt())));
          }
        }

        verifyMetadata(int count, num price) {
          final w =
              tester.widget<Container>(find.byKey(const Key('cart.metadata')));
          final t =
              '${S.orderMetaTotalCount(count)}${MetaBlock.string}${S.orderMetaTotalPrice(price)}';
          expect((w.child as RichText).text.toPlainText(), equals(t));
        }

        verifySnapshot([
          ['p-1', '1'],
          ['p-2', '1'],
        ], 28);

        await tester.tap(find.byKey(const Key('cart.collapsed')));
        await tester.pumpAndSettle();

        verifyProductList(0, title: 'p-1', selected: false);
        verifyProductList(1, title: 'p-2', selected: true);
        verifyMetadata(2, 28);

        expect(find.byKey(const Key('order.ingredient.noNeedIngredient')),
            findsOneWidget);
        await tester.tap(find.byKey(const Key('cart.product.0')));
        await tester.pumpAndSettle();

        verifyProductList(0, selected: true);
        verifyProductList(1, selected: false);

        await tester.tap(find.byKey(const Key('order.quantity.pq-1')));
        await tester.pumpAndSettle();
        verifyProductList(0,
            subtitle: S.orderProductIngredientName('i-1', 'q-1'), price: 27);

        await tester.tap(find.byKey(const Key('order.quantity.default')));
        await tester.pumpAndSettle();
        verifyProductList(0, subtitle: '', price: 17);

        await tester.tap(find.byKey(const Key('order.quantity.pq-2')));
        await tester.pumpAndSettle();
        verifyProductList(0,
            subtitle: S.orderProductIngredientName('i-1', 'q-2'), price: 7);

        await tester.tap(find.byKey(const Key('cart.product.0.add')));
        await tester.tap(find.byKey(const Key('cart.product.1.add')));
        await tester.pumpAndSettle();
        verifyProductList(0, selected: true, price: 14, count: 2);
        verifyProductList(1, selected: false, price: 22, count: 2);
        verifyMetadata(4, 36);

        await tester.tap(find.byKey(const Key('cart.product.1.select')));
        await tester.pumpAndSettle();
        verifyProductList(0, selected: true);
        verifyProductList(1, selected: true);
        expect(find.byKey(const Key('order.ingredient.differentProducts')),
            findsOneWidget);

        await tester.tap(find.byKey(const Key('cart.product.1.select')));
        await tester.pumpAndSettle();
        verifyProductList(0, selected: true);
        verifyProductList(1, selected: false);
        expect(
            tester
                .widget<ChoiceChip>(
                    find.byKey(const Key('order.quantity.pq-2')))
                .selected,
            isTrue);

        await tester.tap(find.byKey(const Key('order.ingredient.pi-2')));
        await tester.pumpAndSettle();
        expect(
            tester
                .widget<ChoiceChip>(
                    find.byKey(const Key('order.quantity.default')))
                .selected,
            isTrue);

        // select all, toggle all
        await tester.tap(find.byKey(const Key('cart.toggle_all')));
        await tester.pumpAndSettle();
        verifyProductList(0, selected: false);
        verifyProductList(1, selected: true);
        await tester.tap(find.byKey(const Key('cart.select_all')));
        await tester.pumpAndSettle();
        verifyProductList(0, selected: true);
        verifyProductList(1, selected: true);

        // close panel
        key.currentState?.slidingPanel.currentState?.reset();
        await tester.pumpAndSettle();

        verifySnapshot([
          ['p-1', '2'],
          ['p-2', '2'],
        ], 36);
      });
    });

    group('All in one page', () {
      testWidgets('scroll to bottom', (tester) async {
        when(cache.get('feat.orderAwakening')).thenReturn(false);
        when(cache.get('feat.orderOutlook')).thenReturn(1);
        // text only
        when(cache.get('feat.orderProductAxisCount')).thenReturn(0);

        prepareData();

        await tester.pumpWidget(MaterialApp(home: orderScreenWidget()));

        await tester.tap(find.byKey(const Key('order.product.p-1')));
        await tester.tap(find.byKey(const Key('order.catalog.c-2')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('order.product.p-2')));
        await tester.tap(find.byKey(const Key('order.product.p-2')));
        await tester.tap(find.byKey(const Key('order.product.p-2')));
        await tester.tap(find.byKey(const Key('order.product.p-2')));
        await tester.tap(find.byKey(const Key('order.product.p-2')));
        await tester.tap(find.byKey(const Key('order.product.p-2')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('cart.collapsed')), findsNothing);
        final scrollController = tester
            .widget<SingleChildScrollView>(
                find.byKey(const Key('cart.product_list')))
            .controller!;
        // scroll to bottom
        expect(scrollController.position.maxScrollExtent, isNonZero);
        expect(find.byKey(const Key('order.orientation.landscape')),
            findsOneWidget);

        // setup portrait env
        tester.binding.window.physicalSizeTestValue = const Size(1000, 2000);

        await tester.pumpAndSettle();
        expect(find.byKey(const Key('order.orientation.portrait')),
            findsOneWidget);

        // resets the screen to its original size after the test end
        tester.binding.window.clearPhysicalSizeTestValue();
      });
    });

    testWidgets('Cart actions', (tester) async {
      Cart.instance.replaceAll(products: [
        OrderProduct(Menu.instance.getProduct('p-1')!, count: 8),
        OrderProduct(Menu.instance.getProduct('p-2')!, isSelected: true),
      ]);

      await tester.pumpWidget(MaterialApp(home: orderScreenWidget()));
      await tester.tap(find.byKey(const Key('cart.collapsed')));
      await tester.pumpAndSettle();

      tapAction(String action, {int? product, String? text}) async {
        if (product == null) {
          await tester.tap(find.byKey(const Key('cart.action')));
          await tester.pumpAndSettle();
        } else {
          await tester.longPress(find.byKey(Key('cart.product.$product')));
          await tester.pumpAndSettle();
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
          expect(tester.widget<Text>(find.byKey(Key('$key.count'))).data,
              equals(count.toString()));
        }
        if (price != null) {
          expect(tester.widget<Text>(find.byKey(Key('$key.price'))).data,
              equals(S.orderCartItemPrice(price.toInt())));
        }
      }

      verifyMetadata(int count, num price) {
        final w =
            tester.widget<Container>(find.byKey(const Key('cart.metadata')));
        final t =
            '${S.orderMetaTotalCount(count)}${MetaBlock.string}${S.orderMetaTotalPrice(price)}';
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

      // discount will use original price.
      await tapAction('discount', text: '50');
      verifyProductList(0, count: 8, price: 15 * 8);
      verifyProductList(1, count: 20, price: 6 * 20);
      verifyMetadata(28, 15 * 8 + 6 * 20);

      await tapAction('free');
      verifyProductList(0, count: 8, price: 0);
      verifyProductList(1, count: 20, price: 0);
      verifyMetadata(28, 0);

      await tapAction('delete', product: 1);
      verifyProductList(0, count: 8, price: 0);
      expect(find.byKey(const Key('cart.product.1')), findsNothing);
      verifyMetadata(8, 0);

      // close panel
      final dynamic widgetsAppState = tester.state(find.byType(WidgetsApp));
      await widgetsAppState.didPopRoute();
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('cart_snapshot.price')).hitTestable(),
          findsOneWidget);
    });

    testWidgets('Ingredient should selected by product', (tester) async {
      await tester.pumpWidget(MaterialApp(home: orderScreenWidget()));

      await tester.tap(find.byKey(const Key('order.product.p-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('order.product.p-3')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('cart.collapsed')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<ChoiceChip>(find.byKey(const Key('order.ingredient.pi-3')))
            .selected,
        isTrue,
      );
    });

    testWidgets('Show different message by cashier status', (tester) async {
      late CashierUpdateStatus cashierStatus;
      OrderAttributes();

      await tester.pumpWidget(MaterialApp(
        routes: {
          Routes.orderDetails: (context) => Scaffold(
                body: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(cashierStatus);
                  },
                  child: const Text('hi', key: Key('test')),
                ),
              ),
        },
        home: orderScreenWidget(),
      ));

      Future<void> tapWithCheck(
        CashierUpdateStatus value, [
        String? expectValue,
      ]) async {
        cashierStatus = value;
        await tester.tap(find.byKey(const Key('order.apply')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('test')));
        await tester.pumpAndSettle();

        if (expectValue != null) {
          expect(find.text(expectValue), findsOneWidget);
          await tester.pump(const Duration(seconds: 3));
        }
      }

      // hide all
      SettingsProvider.of<CashierWarningSetting>().value =
          CashierWarningTypes.hideAll;
      await tapWithCheck(CashierUpdateStatus.ok, S.actSuccess);
      await tapWithCheck(CashierUpdateStatus.notEnough, S.actSuccess);
      await tapWithCheck(CashierUpdateStatus.usingSmall, S.actSuccess);
      // only not enough
      SettingsProvider.of<CashierWarningSetting>().value =
          CashierWarningTypes.onlyNotEnough;
      await tapWithCheck(CashierUpdateStatus.notEnough, '收銀機錢不夠找囉！');
      await tapWithCheck(CashierUpdateStatus.usingSmall, S.actSuccess);
      // show all
      SettingsProvider.of<CashierWarningSetting>().value =
          CashierWarningTypes.showAll;
      await tapWithCheck(CashierUpdateStatus.usingSmall);

      // show tip
      await tester.tap(find.byKey(const Key('order.cashierUsingSmallAction')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('order.cashierUsingSmallAction.tip')),
          findsOneWidget);
      await tester.tapAt(Offset.zero);
    });

    setUp(() {
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
