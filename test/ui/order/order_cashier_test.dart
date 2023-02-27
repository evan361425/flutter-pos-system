import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/order/order_attribute.dart';
import 'package:possystem/models/order/order_attribute_option.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/objects/order_attribute_object.dart';
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
import 'package:possystem/services/storage.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/settings/settings_provider.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/order/order_screen.dart';

import '../../mocks/mock_cache.dart';
import '../../mocks/mock_database.dart';
import '../../mocks/mock_storage.dart';
import '../../test_helpers/translator.dart';

void main() {
  group('Order Cashier', () {
    void prepareData() {
      SettingsProvider(SettingsProvider.allSettings);

      Stock().replaceItems({
        'i-1': Ingredient(id: 'i-1', name: 'i-1', currentAmount: 100),
        'i-2': Ingredient(id: 'i-2', name: 'i-2', currentAmount: 100),
        'i-3': Ingredient(id: 'i-3', name: 'i-3', currentAmount: 100),
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

      OrderAttributes();
      Seller();

      Cart.instance = Cart();
      Cart.instance.replaceAll(products: [
        OrderProduct(Menu.instance.getProduct('p-1')!,
            selectedQuantity: {'pi-1': 'pq-1', 'pi-2': null}),
        OrderProduct(Menu.instance.getProduct('p-2')!),
      ], attributes: {
        'c-1': 'co-1',
        'c-2': 'co-2'
      });
    }

    void prepareOrderAttributes() {
      final s1 = OrderAttribute(
        id: 'c-1',
        mode: OrderAttributeMode.changeDiscount,
        options: {
          'co-1': OrderAttributeOption(
            id: 'co-1',
            isDefault: true,
            modeValue: 10,
          ),
          'co-2': OrderAttributeOption(
            id: 'co-2',
            modeValue: 50,
          ),
        },
      );
      final s2 = OrderAttribute(
        id: 'c-2',
        mode: OrderAttributeMode.changePrice,
        options: {
          'co-3': OrderAttributeOption(
            id: 'co-3',
            modeValue: 10,
          ),
          'co-4': OrderAttributeOption(
            id: 'co-4',
            isDefault: true,
            modeValue: -10,
          ),
        },
      );
      final s3 = OrderAttribute(
        id: 'c-3',
        options: {'co-5': OrderAttributeOption(id: 'co-5', isDefault: true)},
      );
      final s4 = OrderAttribute(
        id: 'c-4',
        options: {'co-6': OrderAttributeOption(id: 'co-6')},
      );
      OrderAttributes.instance.replaceItems({
        'c-1': s1..prepareItem(),
        'c-2': s2..prepareItem(),
        'c-3': s3..prepareItem(),
        'c-4': s4..prepareItem(),
        'c-5': OrderAttribute(id: 'c-5'),
      });
    }

    Finder fCKey(String key) {
      return find.byKey(Key('cashier.calculator.$key'));
    }

    testWidgets('Order without any product', (tester) async {
      Cart.instance = Cart();

      await tester.pumpWidget(
        MaterialApp(routes: Routes.routes, home: const OrderScreen()),
      );

      await tester.tap(find.byKey(const Key('order.apply')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('order.checkout')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('order.action.more')), findsOneWidget);
      expect(find.text(S.actSuccess), findsNothing);
    });

    testWidgets('Order without attributes', (tester) async {
      CurrencySetting.instance.isInt = false;
      final scaffoldMessenger = GlobalKey<ScaffoldMessengerState>();

      await tester.pumpWidget(
        MaterialApp(
          routes: Routes.routes,
          scaffoldMessengerKey: scaffoldMessenger,
          home: const OrderScreen(),
        ),
      );

      await tester.tap(find.byKey(const Key('order.apply')));
      await tester.pumpAndSettle();

      expect(find.text('p-1'), findsOneWidget);

      expect(Cart.instance.totalPrice, equals(28));
      expect(find.byKey(const Key('cashier.snapshot.28')), findsOneWidget);
      expect(find.byKey(const Key('cashier.snapshot.50')), findsOneWidget);
      expect(find.byKey(const Key('cashier.snapshot.100')), findsOneWidget);
      expect(find.byKey(const Key('cashier.snapshot.500')), findsOneWidget);
      expect(find.byKey(const Key('cashier.snapshot.1000')), findsOneWidget);

      await tester.tap(find.byKey(const Key('cashier.snapshot.30')));
      await tester.pumpAndSettle();

      final sChange = find.byKey(const Key('cashier.snapshot.change'));
      expect(tester.widget<Text>(sChange).data,
          equals(S.orderCashierSnapshotChangeField(2)));
      await tester.tap(sChange);
      await tester.pumpAndSettle();

      verifyText(String key, String expectValue) {
        expect(tester.widget<Text>(fCKey(key)).data, equals(expectValue));
      }

      verifyText('paid', '30');
      verifyText('change', '2');

      await tester.tap(fCKey('clear'));
      await tester.tap(fCKey('dot'));
      await tester.tap(fCKey('1'));
      await tester.tap(fCKey('2'));
      await tester.pumpAndSettle();

      verifyText('paid', '0.12');
      expect(
        fCKey('change.error'),
        findsOneWidget,
      );
      await tester.tap(fCKey('submit'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('order.checkout')));
      await tester.pumpAndSettle();

      expect(find.text(S.orderCashierCalculatorChangeNotEnough), findsWidgets);
      // make error message disappear
      scaffoldMessenger.currentState?.hideCurrentSnackBar();
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('cashier.snapshot.change')));
      await tester.pumpAndSettle();
      await tester.tap(fCKey('clear'));
      await tester.pumpAndSettle();

      expect(tester.widget<Text>(fCKey('paid.hint')).data, equals('28'));
      expect(tester.widget<Text>(fCKey('change.hint')).data, equals('0'));

      await tester.tap(fCKey('9'));
      await tester.tap(fCKey('0'));
      await tester.pumpAndSettle();

      verifyText('paid', '90');
      verifyText('change', '62');

      await tester.drag(fCKey('paid'), const Offset(0, 500));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('cashier.snapshot.90')), findsOneWidget);
      expect(tester.widget<Text>(sChange).data, equals('找錢：62'));

      when(database.query(
        any,
        columns: anyNamed('columns'),
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
        limit: anyNamed('limit'),
      )).thenAnswer((_) => Future.value([
            {'id': 1}
          ]));
      when(database.push(any, any)).thenAnswer((_) => Future.value(1));
      await Cashier.instance.setCurrentByUnit(1, 5);

      await tester.tap(find.byKey(const Key('order.checkout')));
      await tester.pumpAndSettle();
      expect(find.text(S.actSuccess), findsOneWidget);

      expect(Cart.instance.isEmpty, isTrue);
      // navigator popped
      expect(sChange, findsNothing);

      verify(storage.set(Stores.cashier, argThat(predicate((data) {
        // 95 - 62
        return data is Map &&
            data['.current'][2]['count'] == 3 &&
            data['.current'][0]['count'] == 3;
      }))));
      verify(storage.set(Stores.stock, argThat(predicate((data) {
        return data is Map &&
            data['i-1.currentAmount'] == 90 &&
            !data.containsKey('i-1.updatedAt') &&
            data['i-2.currentAmount'] == 97 &&
            !data.containsKey('i-1.updatedAt');
      }))));
    });

    testWidgets('With attributes and history mode', (tester) async {
      final scaffoldMessenger = GlobalKey<ScaffoldMessengerState>();
      prepareOrderAttributes();
      Cart.instance.isHistoryMode = true;

      await tester.pumpWidget(
        MaterialApp(
          routes: Routes.routes,
          scaffoldMessengerKey: scaffoldMessenger,
          home: const OrderScreen(),
        ),
      );

      await tester.tap(find.byKey(const Key('order.apply')));
      await tester.pumpAndSettle();

      // go to calculator because of attributes have set.
      expect(find.byKey(const Key('set_attribute.c-1.co-1')), findsNothing);

      await tester.tap(find.byKey(const Key('order.set_attr')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('set_attribute.c-1.co-1')));
      await tester.tap(find.byKey(const Key('set_attribute.c-2.co-3')));

      await tester.tap(find.byKey(const Key('order.cashier')));
      await tester.pumpAndSettle();

      when(database.query(
        any,
        columns: anyNamed('columns'),
        where: anyNamed('where'),
        whereArgs: argThat(equals([',c-2:co-3,c-3:co-5,']), named: 'whereArgs'),
        limit: anyNamed('limit'),
      )).thenAnswer((_) => Future.value([
            {'id': 1}
          ]));
      when(database.getLast(
        Seller.orderTable,
        columns: anyNamed('columns'),
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
        join: anyNamed('join'),
        orderByKey: anyNamed('orderByKey'),
      )).thenAnswer((_) => Future.value({
            'id': 1,
            'encodedProducts': jsonEncode([
              {
                'singlePrice': 10,
                'originalPrice': 10,
                'count': 1,
                'productId': 'p-1',
                'productName': 'p-1',
                'isDiscount': false,
                'ingredients': [
                  {
                    'name': 'i-1',
                    'id': 'i-1',
                    'amount': 2,
                  },
                  {
                    'name': 'i-3',
                    'id': 'i-3',
                    'amount': 5,
                  },
                ]
              },
            ]),
          }));
      when(database.update(Seller.orderTable, 1, any))
          .thenAnswer((_) => Future.value(1));

      await tester.tap(find.byKey(const Key('order.checkout')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm_dialog.cancel')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('order.checkout')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm_dialog.confirm')));
      // wait for error message disappear
      scaffoldMessenger.currentState?.hideCurrentSnackBar();
      await tester.pumpAndSettle();

      expect(find.text(S.actSuccess), findsOneWidget);

      expect(Cart.instance.isEmpty, isTrue);
      // navigator popped
      expect(find.byKey(const Key('order.checkout')), findsNothing);

      verifyNever(database.push('order', any));
      verify(database.update('order', 1, argThat(predicate((e) {
        final deli = String.fromCharCode(13);
        return e is Map &&
            e['paid'] == 38 &&
            e['totalPrice'] == 38 &&
            e['totalCount'] == 2 &&
            e['usedProducts'] == 'p-1${deli}p-2$deli' &&
            e['usedIngredients'] == 'i-1${deli}i-2$deli' &&
            e['encodedAttributes'] ==
                jsonEncode([
                  {
                    "name": "order attribute",
                    "optionName": "order attribute option",
                    "mode": 1,
                    "modeValue": 10
                  },
                  {
                    "name": "order attribute",
                    "optionName": "order attribute option",
                    "mode": 0,
                    "modeValue": null
                  }
                ]) &&
            e['encodedProducts'] ==
                jsonEncode([
                  {
                    "productId": "p-1",
                    "productName": "p-1",
                    "catalogName": "c-1",
                    "count": 1,
                    "cost": 5,
                    "singlePrice": 17,
                    "originalPrice": 17,
                    "isDiscount": false,
                    "ingredients": [
                      {
                        "name": "i-1",
                        "id": "i-1",
                        "productIngredientId": "pi-1",
                        "productQuantityId": "pq-1",
                        "additionalPrice": 10,
                        "additionalCost": 5,
                        "amount": 10,
                        "quantityId": "q-1",
                        "quantityName": "q-1"
                      },
                      {
                        "name": "i-2",
                        "id": "i-2",
                        "productIngredientId": "pi-2",
                        "productQuantityId": null,
                        "additionalPrice": null,
                        "additionalCost": null,
                        "amount": 3,
                        "quantityId": null,
                        "quantityName": null
                      }
                    ]
                  },
                  {
                    "productId": "p-2",
                    "productName": "p-2",
                    "catalogName": "c-2",
                    "count": 1,
                    "cost": 0,
                    "singlePrice": 11,
                    "originalPrice": 11,
                    "isDiscount": false,
                    "ingredients": []
                  }
                ]) &&
            e['productsPrice'] == 28;
      }))));
      verify(storage.set(Stores.cashier, argThat(predicate((data) {
        // 30 + 5 + 3
        return data is Map &&
            data['.current'][2]['count'] == 3 &&
            data['.current'][1]['count'] == 1 &&
            data['.current'][0]['count'] == 3;
      }))));
      verify(storage.set(Stores.stock, argThat(predicate((data) {
        return data is Map &&
            data['i-1.currentAmount'] == 92 &&
            !data.containsKey('i-1.updatedAt') &&
            data['i-2.currentAmount'] == 97 &&
            !data.containsKey('i-2.updatedAt') &&
            data['i-3.currentAmount'] == 105 &&
            !data.containsKey('i-3.updatedAt');
      }))));
    });

    testWidgets('Play with calculator', (tester) async {
      CurrencySetting.instance.isInt = false;
      tester.binding.window.physicalSizeTestValue = const Size(1500, 3000);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpWidget(
        MaterialApp(routes: Routes.routes, home: const OrderScreen()),
      );

      await tester.tap(find.byKey(const Key('order.apply')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('cashier.snapshot.change')));
      await tester.pumpAndSettle();

      // Start testing calculator

      verifyText(String key, String expectValue) {
        expect(tester.widget<Text>(fCKey(key)).data, equals(expectValue));
      }

      await tester.tap(fCKey('3'));
      await tester.tap(fCKey('4'));
      await tester.tap(fCKey('5'));
      await tester.tap(fCKey('plus'));
      await tester.pumpAndSettle();

      verifyText('paid', '345+');
      verifyText('change', '317');

      // drag to show the bellow button
      await tester.drag(fCKey('6'), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.tap(fCKey('6'));
      await tester.tap(fCKey('7'));
      await tester.tap(fCKey('dot'));
      await tester.tap(fCKey('8'));
      await tester.pumpAndSettle();

      verifyText('paid', '345+67.8');
      verifyText('change', '384.8');

      await tester.tap(fCKey('ceil'));
      await tester.pumpAndSettle();

      verifyText('paid', '413');
      verifyText('change', '385');

      await tester.tap(fCKey('minus'));
      await tester.tap(fCKey('6'));
      await tester.pumpAndSettle();

      verifyText('paid', '413-6');
      verifyText('change', '379');
      expect(find.text('='), findsOneWidget);

      await tester.tap(fCKey('clear'));
      await tester.pumpAndSettle();

      expect(find.text('='), findsNothing);

      await tester.tap(fCKey('minus'));
      await tester.tap(fCKey('plus'));
      await tester.tap(fCKey('times'));
      await tester.pumpAndSettle();

      expect(fCKey('paid'), findsNothing);

      await tester.tap(fCKey('3'));
      await tester.tap(fCKey('00'));
      await tester.tap(fCKey('times'));
      await tester.pumpAndSettle();

      verifyText('paid', '300x');
      verifyText('change', '272');

      await tester.tap(fCKey('2'));
      await tester.pumpAndSettle();

      verifyText('paid', '300x2');
      verifyText('change', '572');

      await tester.tap(fCKey('submit'));
      await tester.pumpAndSettle();

      verifyText('paid', '600');
      verifyText('change', '572');
      expect(find.text('='), findsNothing);

      await tester.tap(fCKey('back'));
      await tester.pumpAndSettle();

      verifyText('paid', '60');
      verifyText('change', '32');
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
      reset(database);
    });

    setUpAll(() {
      initializeCache();
      initializeDatabase();
      initializeStorage();
      initializeTranslator();
    });
  });
}
