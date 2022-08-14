import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/models/customer/customer_setting.dart';
import 'package:possystem/models/customer/customer_setting_option.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/objects/order_attribute_object.dart';
import 'package:possystem/models/order/order_product.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/models/repository/customer_settings.dart';
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

      CustomerSettings();
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

    void prepareCustomerSettings() {
      final s1 = CustomerSetting(
        id: 'c-1',
        mode: OrderAttributeMode.changeDiscount,
        options: {
          'co-1': CustomerSettingOption(
            id: 'co-1',
            isDefault: true,
            modeValue: 10,
          ),
          'co-2': CustomerSettingOption(
            id: 'co-2',
            modeValue: 50,
          ),
        },
      );
      final s2 = CustomerSetting(
        id: 'c-2',
        mode: OrderAttributeMode.changePrice,
        options: {
          'co-3': CustomerSettingOption(
            id: 'co-3',
            modeValue: 10,
          ),
          'co-4': CustomerSettingOption(
            id: 'co-4',
            isDefault: true,
            modeValue: -10,
          ),
        },
      );
      final s3 = CustomerSetting(
        id: 'c-3',
        options: {'co-5': CustomerSettingOption(id: 'co-5', isDefault: true)},
      );
      final s4 = CustomerSetting(
        id: 'c-4',
        options: {'co-6': CustomerSettingOption(id: 'co-6')},
      );
      CustomerSettings.instance.replaceItems({
        'c-1': s1..prepareItem(),
        'c-2': s2..prepareItem(),
        'c-3': s3..prepareItem(),
        'c-4': s4..prepareItem(),
        'c-5': CustomerSetting(id: 'c-5'),
      });
    }

    testWidgets('Order without any product', (tester) async {
      Cart.instance = Cart();

      await tester.pumpWidget(
        MaterialApp(routes: Routes.routes, home: const OrderScreen()),
      );

      await tester.tap(find.byKey(const Key('order.cashier')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('cashier.order')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('order.action.more')), findsOneWidget);
      expect(find.text(S.actSuccess), findsNothing);
    });

    testWidgets('Order without customer setting', (tester) async {
      CurrencySetting.instance.isInt = false;
      tester.binding.window.physicalSizeTestValue = const Size(1000, 3000);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpWidget(
        MaterialApp(routes: Routes.routes, home: const OrderScreen()),
      );

      await tester.tap(find.byKey(const Key('order.cashier')));
      await tester.pumpAndSettle();

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
        expect(
          tester.widget<Text>(find.byKey(Key('cashier.calculator.$key'))).data,
          equals(expectValue),
        );
      }

      verifyText('paid', '30');
      verifyText('change', '2');

      await tester.tap(find.byKey(const Key('cashier.calculator.clear')));
      await tester.tap(find.byKey(const Key('cashier.calculator.dot')));
      await tester.tap(find.byKey(const Key('cashier.calculator.1')));
      await tester.tap(find.byKey(const Key('cashier.calculator.2')));
      await tester.pumpAndSettle();

      verifyText('paid', '0.12');
      expect(
        find.byKey(const Key('cashier.calculator.change.error')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('cashier.calculator.submit')));
      await tester.pump();
      expect(find.text(S.orderCashierCalculatorChangeNotEnough), findsWidgets);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('cashier.calculator.clear')));
      await tester.tap(find.byKey(const Key('cashier.calculator.3')));
      await tester.tap(find.byKey(const Key('cashier.calculator.4')));
      await tester.tap(find.byKey(const Key('cashier.calculator.5')));
      await tester.tap(find.byKey(const Key('cashier.calculator.6')));
      await tester.tap(find.byKey(const Key('cashier.calculator.7')));
      await tester.tap(find.byKey(const Key('cashier.calculator.dot')));
      await tester.tap(find.byKey(const Key('cashier.calculator.8')));
      await tester.tap(find.byKey(const Key('cashier.calculator.ceil')));
      await tester.pumpAndSettle();

      verifyText('paid', '34568');
      verifyText('change', '34540');

      await tester.tap(find.byKey(const Key('cashier.calculator.back')));
      await tester.pumpAndSettle();

      verifyText('paid', '3456');
      verifyText('change', '3428');

      await tester.tap(find.byKey(const Key('cashier.calculator.clear')));
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<HintText>(
                find.byKey(const Key('cashier.calculator.paid.hint')))
            .text,
        equals('28'),
      );
      expect(
        tester
            .widget<HintText>(
                find.byKey(const Key('cashier.calculator.change.hint')))
            .text,
        equals('0'),
      );

      await tester.tap(find.byKey(const Key('cashier.calculator.9')));
      await tester.tap(find.byKey(const Key('cashier.calculator.0')));
      await tester.pumpAndSettle();

      verifyText('paid', '90');
      verifyText('change', '62');

      await tester.drag(
        find.byKey(const Key('cashier.calculator.paid')),
        const Offset(0, 500),
      );
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

      await tester.tap(find.byKey(const Key('cashier.order')));
      // wait for error message disappear
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text(S.actSuccess), findsOneWidget);

      expect(Cart.instance.isEmpty, isTrue);
      // navigator poped
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
            data['i-1.updatedAt'] != null &&
            data['i-2.currentAmount'] == 97 &&
            data['i-2.updatedAt'] != null;
      }))));
    });

    testWidgets('With customer setting and history mode', (tester) async {
      prepareCustomerSettings();
      Cart.instance.isHistoryMode = true;

      await tester.pumpWidget(
        MaterialApp(
          routes: Routes.routes,
          home: const OrderScreen(),
        ),
      );

      await tester.tap(find.byKey(const Key('order.cashier')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('set_attribute.c-1.co-1')));
      await tester.tap(find.byKey(const Key('set_attribute.c-2.co-3')));

      await tester.tap(find.byKey(const Key('set_attribute.next')));
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

      await tester.tap(find.byKey(const Key('cashier.order')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm_dialog.cancel')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('cashier.order')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm_dialog.confirm')));
      // wait for error message disappear
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text(S.actSuccess), findsOneWidget);

      expect(Cart.instance.isEmpty, isTrue);
      // navigator poped
      expect(find.byKey(const Key('cashier.order')), findsNothing);

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
            data['i-1.updatedAt'] != null &&
            data['i-2.currentAmount'] == 97 &&
            data['i-2.updatedAt'] != null &&
            data['i-3.currentAmount'] == 105 &&
            data['i-3.updatedAt'] != null;
      }))));
    });

    setUp(() {
      // disable and features
      when(cache.get(any)).thenReturn(null);

      prepareData();
      Cashier().setCurrent(null);
    });

    setUpAll(() {
      initializeCache();
      initializeDatabase();
      initializeStorage();
      initializeTranslator();
    });
  });
}
