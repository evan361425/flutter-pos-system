import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/components/imageable_container.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/objects/order_attribute_object.dart';
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
import 'package:possystem/services/bluetooth.dart';
import 'package:possystem/services/storage.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/order/order_page.dart';
import 'package:provider/provider.dart';

import '../../mocks/mock_bluetooth.dart';
import '../../mocks/mock_bluetooth.mocks.dart';
import '../../mocks/mock_cache.dart';
import '../../mocks/mock_database.dart';
import '../../mocks/mock_storage.dart';
import '../../test_helpers/breakpoint_mocker.dart';
import '../../test_helpers/order_setter.dart';
import '../../test_helpers/translator.dart';

void main() {
  group('Order Details', () {
    void prepareData() {
      Printers();
      Stock().replaceItems({
        'i-1': Ingredient(id: 'i-1', name: 'i-1', currentAmount: 100),
        'i-2': Ingredient(id: 'i-2', name: 'i-2', currentAmount: 100),
        'i-3': Ingredient(id: 'i-3', name: 'i-3', currentAmount: 100),
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

      Cart.instance = Cart();
      Cart.instance.replaceAll(products: [
        CartProduct(Menu.instance.getProduct('p-1')!, quantities: {'pi-1': 'pq-1'}),
        CartProduct(Menu.instance.getProduct('p-2')!),
      ], attributes: {
        'oa-1': 'oao-1',
        'oa-2': 'oao-2'
      });
    }

    void prepareOrderAttributes() {
      final s1 = OrderAttribute(
        id: 'oa-1',
        name: 'oa-1',
        mode: OrderAttributeMode.changeDiscount,
        options: {
          'oao-1': OrderAttributeOption(
            id: 'oao-1',
            name: 'oao-1',
            isDefault: true,
            modeValue: 10,
          ),
          'oao-2': OrderAttributeOption(
            id: 'oao-2',
            name: 'oao-2',
            modeValue: 50,
          ),
        },
      );
      final s2 = OrderAttribute(
        id: 'oa-2',
        name: 'oa-2',
        mode: OrderAttributeMode.changePrice,
        options: {
          'oao-3': OrderAttributeOption(
            id: 'oao-3',
            name: 'oao-3',
            modeValue: 10,
          ),
          'oao-4': OrderAttributeOption(
            id: 'oao-4',
            name: 'oao-4',
            isDefault: true,
            modeValue: -10,
          ),
        },
      );
      final s3 = OrderAttribute(
        id: 'oa-3',
        name: 'oa-3',
        options: {
          'oao-5': OrderAttributeOption(
            id: 'oao-5',
            name: 'oao-5',
            isDefault: true,
          )
        },
      );
      final s4 = OrderAttribute(
        id: 'oa-4',
        name: 'oa-4',
        options: {'oao-6': OrderAttributeOption(id: 'oao-6', name: 'oao-6')},
      );
      OrderAttributes.instance.replaceItems({
        'oa-1': s1..prepareItem(),
        'oa-2': s2..prepareItem(),
        'oa-3': s3..prepareItem(),
        'oa-4': s4..prepareItem(),
        'oa-5': OrderAttribute(id: 'oa-5', name: 'oa-5'),
      });
    }

    /// syntax for finding calculator key
    Finder fCKey(String key) {
      return find.byKey(Key('cashier.calculator.$key'));
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

    for (final device in [Device.mobile, Device.desktop]) {
      group(device, () {
        testWidgets('Order without any product', (tester) async {
          deviceAs(device, tester);
          Cart.instance = Cart();
          // deviceAs(device, tester);

          await tester.pumpWidget(buildApp());

          await tester.tap(find.byKey(const Key('order.checkout')));
          await tester.pumpAndSettle();

          await tester.tap(find.text(S.orderCheckoutDetailsTab));
          await tester.pumpAndSettle();

          expect(find.byKey(const Key('order.details.confirm')), findsNothing);
        });

        testWidgets('Order without attributes but with printer', (tester) async {
          final printer = MockPrinter();
          final manufactory = MockPrinterManufactory();
          final btDevice = MockBluetoothDevice();
          deviceAs(device, tester);
          prepareImageable(Future.value([ConvertibleImage(Uint8List(32), width: 8)]));
          CurrencySetting.instance.isInt = false;
          Printers.instance.replaceItems({
            '1': Printer(id: '1', name: '1')..p = printer,
          });
          when(printer.connected).thenReturn(true);
          when(printer.manufactory).thenReturn(manufactory);
          when(printer.statusStream).thenAnswer((_) => Stream.value(PrinterStatus.good));
          when(printer.draw(any, density: anyNamed('density'))).thenAnswer((_) => Stream.value(1.0));
          when(printer.device).thenReturn(btDevice);
          when(manufactory.widthBits).thenReturn(8);
          when(btDevice.createSignalStream()).thenAnswer((_) => Stream.value(BluetoothSignal.normal));

          await tester.pumpWidget(buildApp());

          await tester.tap(find.byKey(const Key('order.checkout')));
          await tester.pumpAndSettle();

          expect(find.byKey(const Key('order.attr_note')), findsOneWidget);

          await tester.tap(find.text(S.orderCheckoutDetailsTab));
          await tester.pumpAndSettle();

          expect(Cart.instance.price, equals(28));
          expect(find.byKey(const Key('cashier.snapshot.28')), findsOneWidget);
          expect(find.byKey(const Key('cashier.snapshot.50')), findsOneWidget);
          expect(find.byKey(const Key('cashier.snapshot.100')), findsOneWidget);
          expect(find.byKey(const Key('cashier.snapshot.500')), findsOneWidget);
          expect(find.byKey(const Key('cashier.snapshot.1000'), skipOffstage: false), findsOneWidget);

          await tester.tap(find.byKey(const Key('cashier.snapshot.30')));
          await tester.pumpAndSettle();

          // only mobile has this change text and allow to drag
          if (device == Device.mobile) {
            expect(find.text(S.orderCheckoutDetailsSnapshotLabelChange('2')), findsOneWidget);
            await tester.drag(
              find.byKey(const Key('order.details.ds')),
              const Offset(0, -408),
            );
            await tester.pumpAndSettle();
          }

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
          expect(fCKey('change.error'), findsOneWidget);
          await tester.tap(fCKey('submit'));
          await tester.pumpAndSettle();

          expect(find.text(S.orderCheckoutSnackbarPaidFailed), findsWidgets);

          await tester.tap(fCKey('clear'));
          await tester.pumpAndSettle();

          expect(tester.widget<Text>(fCKey('paid.hint')).data, equals('28'));
          expect(tester.widget<Text>(fCKey('change.hint')).data, equals('0'));

          await tester.tap(fCKey('9'));
          await tester.tap(fCKey('0'));
          await tester.pumpAndSettle();

          verifyText('paid', '90');
          verifyText('change', '62');

          // tap outside to close draggable
          if (device == Device.mobile) {
            await tester.tapAt(const Offset(400, 161));
            await tester.pumpAndSettle();

            expect(find.text(S.orderCheckoutDetailsSnapshotLabelChange('62')), findsOneWidget);
          }

          expect(find.byKey(const Key('cashier.snapshot.90')), findsOneWidget);

          await Cashier.instance.setCurrentByUnit(1, 5);

          final now = DateTime.now();
          Cart.timer = () => now;
          final checker = OrderSetter.setPushed(OrderObject(
            id: 1,
            paid: 90,
            price: 28,
            cost: 5,
            productsPrice: 28,
            productsCount: 2,
            createdAt: now,
            products: const [
              OrderProductObject(
                id: 1,
                productName: "p-1",
                catalogName: "c-1",
                count: 1,
                singleCost: 5,
                singlePrice: 17,
                originalPrice: 17,
                isDiscount: false,
                ingredients: [
                  OrderIngredientObject(
                    ingredientName: 'i-1',
                    quantityName: 'q-1',
                    additionalPrice: 10,
                    additionalCost: 5,
                    amount: 5,
                  ),
                  OrderIngredientObject(
                    ingredientName: 'i-2',
                    quantityName: null,
                    additionalPrice: 0,
                    additionalCost: 0,
                    amount: 3,
                  ),
                ],
              ),
              OrderProductObject(
                id: 1,
                productName: "p-2",
                catalogName: "c-2",
                count: 1,
                singleCost: 0,
                singlePrice: 11,
                originalPrice: 11,
                isDiscount: false,
              ),
            ],
          ));
          await tester.tap(find.byKey(const Key('order.details.confirm')));
          await tester.pumpAndSettle();
          expect(find.text(S.actSuccess), findsOneWidget);

          expect(Cart.instance.isEmpty, isTrue);
          // navigator popped
          expect(find.byKey(const Key('order.details.ds')), findsNothing);

          checker();

          verify(storage.set(Stores.cashier, argThat(predicate((data) {
            // 95 - 62
            return data is Map && data['.current'][2]['count'] == 3 && data['.current'][0]['count'] == 3;
          }))));
          verify(storage.set(Stores.stock, argThat(predicate((data) {
            return data is Map &&
                data['i-1.currentAmount'] == 95 &&
                !data.containsKey('i-1.updatedAt') &&
                data['i-2.currentAmount'] == 97 &&
                !data.containsKey('i-2.updatedAt');
          }))));
          verify(printer.draw(any, density: anyNamed('density'))).called(1);

          if (device == Device.desktop) {
            // FIXME: I've no idea why this error happened
            expect('${tester.binding.takeException()}', 'A RenderFlex overflowed by 299 pixels on the right.');
          }
        });

        testWidgets('Order with attributes', (tester) async {
          deviceAs(device, tester);
          prepareOrderAttributes();
          Cart.instance.note = 'note';

          await tester.pumpWidget(buildApp());

          await tester.tap(find.byKey(const Key('order.checkout')));
          await tester.pumpAndSettle();

          await tester.tap(find.byKey(const Key('order.attr.oa-1.oao-1')));
          await tester.tap(find.byKey(const Key('order.attr.oa-2.oao-3')));

          final note = find.byKey(const Key('order.attr_note')).first.evaluate().first.widget as TextField;
          expect(note.controller!.text, equals('note'));
          await tester.enterText(find.byKey(const Key('order.attr_note')), 'new note');

          await tester.tap(find.text(S.orderCheckoutDetailsTab));
          await tester.pumpAndSettle();

          final now = DateTime.now();
          Cart.timer = () => now;
          final checker = OrderSetter.setPushed(OrderObject(
            id: 1,
            paid: 38,
            price: 38,
            cost: 5,
            productsPrice: 28,
            productsCount: 2,
            note: 'new note',
            createdAt: now,
            products: const [
              OrderProductObject(
                id: 1,
                productName: "p-1",
                catalogName: "c-1",
                count: 1,
                singleCost: 5,
                singlePrice: 17,
                originalPrice: 17,
                isDiscount: false,
                ingredients: [
                  OrderIngredientObject(
                    ingredientName: "i-1",
                    quantityName: "q-1",
                    additionalPrice: 10,
                    additionalCost: 5,
                    amount: 5,
                  ),
                  OrderIngredientObject(
                    ingredientName: "i-2",
                    amount: 3,
                  ),
                ],
              ),
              OrderProductObject(
                id: 2,
                productName: "p-2",
                catalogName: "c-2",
                count: 1,
                singleCost: 0,
                singlePrice: 11,
                originalPrice: 11,
                isDiscount: false,
              ),
            ],
            attributes: const [
              OrderSelectedAttributeObject(
                name: 'oa-2',
                optionName: 'oao-3',
                mode: OrderAttributeMode.changePrice,
                modeValue: 10,
              ),
              OrderSelectedAttributeObject(
                name: 'oa-3',
                optionName: 'oao-5',
                mode: OrderAttributeMode.statOnly,
              ),
            ],
          ));

          await tester.tap(find.byKey(const Key('order.details.confirm')));
          await tester.pumpAndSettle();
          await tester.pumpAndSettle();

          checker();

          verify(storage.set(Stores.cashier, argThat(predicate((data) {
            // 30 + 5 + 3
            return data is Map &&
                data['.current'][2]['count'] == 3 &&
                data['.current'][1]['count'] == 1 &&
                data['.current'][0]['count'] == 3;
          }))));
          verify(storage.set(Stores.stock, argThat(predicate((data) {
            return data is Map &&
                data['i-1.currentAmount'] == 95 &&
                !data.containsKey('i-1.updatedAt') &&
                data['i-2.currentAmount'] == 97 &&
                !data.containsKey('i-2.updatedAt');
          }))));

          expect(find.text(S.actSuccess), findsOneWidget);
          expect(Cart.instance.isEmpty, isTrue);
          expect(find.byKey(const Key('order.details.confirm')), findsNothing);
        });

        testWidgets('is able to stash the order', (tester) async {
          deviceAs(device, tester);
          // only test available and actual function was test by other test case.
          when(database.push(StashedOrders.table, any)).thenAnswer((_) => Future.value(1));

          await tester.pumpWidget(buildApp());
          await tester.pumpAndSettle();

          await tester.tap(find.byKey(const Key('order.checkout')));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const Key('order.details.stash')));
          await tester.pumpAndSettle();

          expect(find.text(S.actSuccess), findsOneWidget);
        });
      });
    }

    testWidgets('Play with calculator', (tester) async {
      CurrencySetting.instance.isInt = false;
      deviceAs(Device.mobile, tester);

      await tester.pumpWidget(buildApp());

      await tester.tap(find.byKey(const Key('order.checkout')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('order.details.order')));
      await tester.pumpAndSettle();

      await tester.drag(
        find.byKey(const Key('order.details.ds')),
        const Offset(0, -408),
      );
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
