import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/debug/random_gen_order.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/objects/order_attribute_object.dart';
import 'package:possystem/models/order/order_attribute.dart';
import 'package:possystem/models/order/order_attribute_option.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:provider/provider.dart';

import '../mocks/mock_database.dart';
import '../mocks/mock_database.mocks.dart';

void main() {
  group('Random Generate Order', () {
    test('no gen if same date', () {
      final now = DateTime.now();
      final result = generateOrders(
        orderCount: 10,
        startFrom: now,
        endTo: now,
      );

      expect(result, isEmpty);
    });

    test('default setting', () {
      final end = DateTime.now();
      final result = generateOrders(
        orderCount: 10,
        startFrom: end.subtract(const Duration(days: 1)),
        endTo: end,
      );

      expect(result.length, equals(10));
      expect(result.map((e) => e.productsCount).reduce((a, b) => a + b), greaterThanOrEqualTo(10));
      expect(result.fold<int>(0, (pre, e) => e.attributes.length + pre), greaterThan(0));
    });

    testWidgets('change date and count', (tester) async {
      final txn = MockDatabaseExecutor();
      final batch = MockBatch();

      when(database.transaction(any)).thenAnswer((inv) => inv.positionalArguments[0](txn));
      when(txn.batch()).thenReturn(batch);
      when(txn.insert(Seller.orderTable, any)).thenAnswer((_) => Future.value(1));
      when(txn.insert(Seller.productTable, any)).thenAnswer((_) => Future.value(1));
      when(batch.commit(noResult: anyNamed('noResult'))).thenAnswer((_) => Future.value([]));

      const btn = Key('test');
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: Seller.instance,
        child: MaterialApp(home: Builder(builder: (context) {
          return TextButton(
            key: btn,
            onPressed: goGenerateRandomOrders(context),
            child: const Text('test'),
          );
        })),
      ));

      await tester.tap(find.byKey(btn));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('rgo.count')), '15');
      await tester.tap(find.byKey(const Key('rgo.date_range')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'), warnIfMissed: false);
      await tester.pumpAndSettle();

      await tester.tap(find.text('OK'), warnIfMissed: false);
      await tester.pumpAndSettle();

      verify(txn.insert(Seller.orderTable, any)).called(15);
    });
  });

  setUpAll(() {
    final stock = Stock()
      ..replaceItems({
        'i-1': Ingredient(id: 'i-1', name: 'i-1'),
        'i-2': Ingredient(id: 'i-2', name: 'i-2'),
        'i-3': Ingredient(id: 'i-3', name: 'i-3'),
      });
    final qs = Quantities()
      ..replaceItems({
        'q-1': Quantity(id: 'q-1', name: 'q-1'),
        'q-2': Quantity(id: 'q-2', name: 'q-2'),
        'q-3': Quantity(id: 'q-3', name: 'q-3'),
      });
    // Order Attributes
    final attrs = OrderAttributes();
    attrs.replaceItems({
      'at-1': OrderAttribute(id: 'at-1', name: 'at-1'),
      'at-2': OrderAttribute(id: 'at-2', name: 'at-2', mode: OrderAttributeMode.changePrice, options: {
        'o1': OrderAttributeOption(id: 'o1', name: 'o1', modeValue: 1),
        'o2': OrderAttributeOption(id: 'o2', name: 'o2', modeValue: 2),
        'o3': OrderAttributeOption(id: 'o3', name: 'o3', modeValue: 3),
        'o4': OrderAttributeOption(id: 'o4', name: 'o4', modeValue: 4),
        'o5': OrderAttributeOption(id: 'o5', name: 'o5', modeValue: 5.0),
        'o6': OrderAttributeOption(id: 'o6', name: 'o6', modeValue: 6.1),
        'o7': OrderAttributeOption(id: 'o7', name: 'o7', modeValue: 7.2),
        'o8': OrderAttributeOption(id: 'o8', name: 'o8', modeValue: 8),
        'o9': OrderAttributeOption(id: 'o9', name: 'o9', modeValue: null),
        'o0': OrderAttributeOption(id: 'o0', name: 'o0', modeValue: null),
      })
        ..prepareItem(),
    });
    // Menu
    final q1 = ProductQuantity(
      id: 'pq-1',
      quantity: qs.getItem('q-1'),
      additionalCost: 1,
      additionalPrice: 1,
      amount: 1,
    );
    final q2 = ProductQuantity(
      id: 'pq-2',
      quantity: qs.getItem('q-2'),
      additionalCost: 3,
      additionalPrice: 3,
      amount: 3,
    );
    final q3 = ProductQuantity(
      id: 'pq-3',
      quantity: qs.getItem('q-3'),
      additionalCost: -5,
      additionalPrice: -5,
      amount: -5,
    );
    final i1 = ProductIngredient(
      id: 'pi-1',
      ingredient: stock.getItem('i-1'),
      amount: 11,
      quantities: {'pq-1': q1, 'p1-2': q2},
    )..prepareItem();
    final i2 = ProductIngredient(
      id: 'pi-2',
      ingredient: stock.getItem('i-2'),
      amount: 13,
      quantities: {'pq-3': q3},
    )..prepareItem();
    final i3 = ProductIngredient(
      id: 'pi-3',
      ingredient: stock.getItem('i-3'),
      amount: 13,
    );
    final p1 = Product(
      id: 'p-1',
      name: 'p-1',
      cost: 17,
      price: 23,
      ingredients: {'pi-1': i1, 'pi-2': i2},
    )..prepareItem();
    final p2 = Product(
      id: 'p-2',
      name: 'p-2',
      cost: 29,
      price: 31,
      ingredients: {'pi-3': i3},
    )..prepareItem();
    final p3 = Product(id: 'p-3', name: 'p-3', cost: 37, price: 41);
    Menu().replaceItems({
      'c-1': Catalog(id: 'c-1', products: {'p-1': p1, 'p-2': p2, 'p-3': p3})..prepareItem()
    });

    initializeDatabase();
  });
}
