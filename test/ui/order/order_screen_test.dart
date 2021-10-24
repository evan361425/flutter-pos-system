import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/radio_text.dart';
import 'package:possystem/components/style/outlined_text.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/order/order_product.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/providers/currency_provider.dart';
import 'package:possystem/services/cache.dart';
import 'package:possystem/ui/order/order_screen.dart';

import '../../mocks/mock_cache.dart';

void main() {
  group('Order Screen', () {
    void prepareData() {
      Stock().replaceItems({
        'i-1': Ingredient(id: 'i-1', name: 'i-1'),
        'i-2': Ingredient(id: 'i-2', name: 'i-2'),
      });
      Quantities().replaceItems({
        'q-1': Quantity(id: 'q-1', name: 'q-1'),
        'q-2': Quantity(id: 'q-2', name: 'q-2')
      });
      final ingreidnet1 = ProductIngredient(
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
      final ingreidnet2 = ProductIngredient(
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
      final product = Product(id: 'p-1', name: 'p-1', price: 17, ingredients: {
        'pi-1': ingreidnet1..prepareItem(),
        'pi-2': ingreidnet2..prepareItem(),
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

      // setup model
      Seller();
      Cart.instance = Cart();
    }

    group('Slidable Panel', () {
      testWidgets('Selecting change state', (tester) async {
        final key = GlobalKey<OrderScreenState>();
        await tester.pumpWidget(MaterialApp(home: OrderScreen(key: key)));

        await tester.tap(find.byKey(Key('order.product.p-1')));
        await tester.tap(find.byKey(Key('order.catalog.c-2')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(Key('order.product.p-2')));
        await tester.pumpAndSettle();

        final verifySnapshot = (List<List<String>> data, num price) {
          var count = 0;
          data.forEach((item) {
            final w = tester.widget<OutlinedText>(
                find.byKey(Key('cart_snapshot.${count++}')));
            expect(w.text, equals(item[0]));
            expect(w.badge, equals(item[1]));
          });
          final w = tester.widget<Text>(find.byKey(Key('cart_snapshot.price')));
          expect(w.data, equals(price.toString()));
        };

        final verifyProductList = (
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
                equals('price-$price'));
          }
        };

        final verifyMetadata = (int count, num price) {
          final w = tester.widget<Container>(find.byKey(Key('cart.metadata')));
          final t = 'total_count-$count${MetaBlock.string}total_price-$price';
          expect((w.child as RichText).text.toPlainText(), equals(t));
        };

        verifySnapshot([
          ['p-1', '1'],
          ['p-2', '1'],
        ], 28);

        await tester.tap(find.byKey(Key('cart.collapsed')));
        await tester.pumpAndSettle();

        verifyProductList(0, title: 'p-1', selected: false);
        verifyProductList(1, title: 'p-2', selected: true);
        verifyMetadata(2, 28);

        expect(find.byKey(Key('order.ingredient.no_quantity')), findsOneWidget);
        await tester.tap(find.byKey(Key('cart.product.0')));
        await tester.pumpAndSettle();

        verifyProductList(0, selected: true);
        verifyProductList(1, selected: false);

        await tester.tap(find.byKey(Key('order.quantity.pq-1')));
        await tester.pumpAndSettle();
        verifyProductList(0, subtitle: 'i-1 - q-1', price: 27);

        await tester.tap(find.byKey(Key('order.quantity.default')));
        await tester.pumpAndSettle();
        verifyProductList(0, subtitle: '', price: 17);

        await tester.tap(find.byKey(Key('order.quantity.pq-2')));
        await tester.pumpAndSettle();
        verifyProductList(0, subtitle: 'i-1 - q-2', price: 7);

        await tester.tap(find.byKey(Key('cart.product.0.add')));
        await tester.tap(find.byKey(Key('cart.product.1.add')));
        await tester.pumpAndSettle();
        verifyProductList(0, selected: true, price: 14, count: 2);
        verifyProductList(1, selected: false, price: 22, count: 2);
        verifyMetadata(4, 36);

        await tester.tap(find.byKey(Key('cart.product.1.select')));
        await tester.pumpAndSettle();
        verifyProductList(0, selected: true);
        verifyProductList(1, selected: true);
        expect(find.byKey(Key('order.ingredient.not_same_product')),
            findsOneWidget);

        await tester.tap(find.byKey(Key('cart.product.1.select')));
        await tester.pumpAndSettle();
        verifyProductList(0, selected: true);
        verifyProductList(1, selected: false);
        expect(
            tester
                .widget<RadioText>(find.byKey(Key('order.quantity.pq-2')))
                .isSelected,
            isTrue);

        await tester.tap(find.byKey(Key('order.ingredient.pi-2')));
        await tester.pumpAndSettle();
        expect(
            tester
                .widget<RadioText>(find.byKey(Key('order.quantity.default')))
                .isSelected,
            isTrue);

        // select all, toggle all
        await tester.tap(find.byKey(Key('cart.toggle_all')));
        await tester.pumpAndSettle();
        verifyProductList(0, selected: false);
        verifyProductList(1, selected: true);
        await tester.tap(find.byKey(Key('cart.select_all')));
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
        when(cache.get(Caches.feature_awake_provider)).thenReturn(false);
        when(cache.get(Caches.outlook_order)).thenReturn(1);

        prepareData();

        await tester.pumpWidget(MaterialApp(home: OrderScreen()));

        await tester.tap(find.byKey(Key('order.product.p-1')));
        await tester.tap(find.byKey(Key('order.catalog.c-2')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(Key('order.product.p-2')));
        await tester.tap(find.byKey(Key('order.product.p-2')));
        await tester.tap(find.byKey(Key('order.product.p-2')));
        await tester.tap(find.byKey(Key('order.product.p-2')));
        await tester.tap(find.byKey(Key('order.product.p-2')));
        await tester.tap(find.byKey(Key('order.product.p-2')));
        await tester.pumpAndSettle();

        expect(find.byKey(Key('cart.collapsed')), findsNothing);
        final scrollController = tester
            .widget<SingleChildScrollView>(find.byKey(Key('cart.product_list')))
            .controller!;
        // scroll to bottom
        expect(scrollController.position.maxScrollExtent, isNonZero);
        expect(find.byKey(Key('order.orientation.lanscape')), findsOneWidget);

        // setup portrait env
        tester.binding.window.physicalSizeTestValue = Size(1000, 2000);

        await tester.pumpAndSettle();
        expect(find.byKey(Key('order.orientation.portrait')), findsOneWidget);

        // resets the screen to its orinal size after the test end
        tester.binding.window.clearPhysicalSizeTestValue();
      });
    });

    testWidgets('Cart actions', (tester) async {
      final currency = CurrencyProvider();
      when(cache.set(any, any)).thenAnswer((_) => Future.value(true));
      await currency.setCurrency(CurrencyTypes.TWD);

      Cart.instance.replaceAll(products: [
        OrderProduct(Menu.instance.getProduct('p-1')!, count: 8),
        OrderProduct(Menu.instance.getProduct('p-2')!, isSelected: true),
      ]);

      await tester.pumpWidget(MaterialApp(home: OrderScreen()));
      await tester.tap(find.byKey(Key('cart.collapsed')));
      await tester.pumpAndSettle();

      final tapAction = (String action, {int? product, String? text}) async {
        if (product == null) {
          await tester.tap(find.byKey(Key('cart.action')));
          await tester.pumpAndSettle();
        } else {
          await tester.longPress(find.byKey(Key('cart.product.$product')));
          await tester.pumpAndSettle();
        }

        await tester.tap(find.byKey(Key('cart.action.$action')));
        await tester.pumpAndSettle();

        if (text != null) {
          await tester.enterText(find.byType(TextFormField), text);
          await tester.tap(find.byKey(Key('text_dialog.confirm')));
          await tester.pumpAndSettle();
        }
      };

      final verifyProductList = (int index, {int? count, num? price}) {
        final key = 'cart.product.$index';
        if (count != null) {
          expect(tester.widget<Text>(find.byKey(Key('$key.count'))).data,
              equals(count.toString()));
        }
        if (price != null) {
          expect(tester.widget<Text>(find.byKey(Key('$key.price'))).data,
              equals('price-$price'));
        }
      };

      final verifyMetadata = (int count, num price) {
        final w = tester.widget<Container>(find.byKey(Key('cart.metadata')));
        final t = 'total_count-$count${MetaBlock.string}total_price-$price';
        expect((w.child as RichText).text.toPlainText(), equals(t));
      };

      await tapAction('count', text: '20');
      verifyProductList(0, count: 8, price: 17 * 8);
      verifyProductList(1, count: 20, price: 11 * 20);
      verifyMetadata(28, 17 * 8 + 11 * 20);

      await tapAction('price', product: 0, text: '30');
      verifyProductList(0, count: 8, price: 30 * 8);
      verifyProductList(1, count: 20, price: 11 * 20);
      verifyMetadata(28, 30 * 8 + 11 * 20);

      await tester.tap(find.byKey(Key('cart.product.1.select')));
      await tester.pumpAndSettle();

      // discount will use original price.
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
      expect(find.byKey(Key('cart.product.1')), findsNothing);
      verifyMetadata(8, 0);
    });

    setUp(() {
      // disable feature and tips
      when(cache.getRaw(any)).thenReturn(1);
      when(cache.get(any)).thenReturn(null);

      prepareData();
    });

    setUpAll(() {
      initializeCache();
    });
  });
}
