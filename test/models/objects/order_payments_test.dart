import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/order/payment_intent.dart';

void main() {
  group('PaymentIntent & OrderObject payments', () {
    test('PaymentIntent serializes method by name', () {
      const intent = PaymentIntent(amount: 12.5, method: PaymentMethod.card);
      expect(intent.toMap(), {'amount': 12.5, 'method': 'card'});
      expect(PaymentIntent.fromMap({'amount': 12.5, 'method': 'card'}), intent);
    });

    test('OrderObject paid getter sums payment intents', () {
      final order = OrderObject(
        createdAt: DateTime(2024, 1, 1),
        price: 100,
        payments: const [
          PaymentIntent(amount: 40, method: PaymentMethod.cash),
          PaymentIntent(amount: 60, method: PaymentMethod.card),
        ],
      );
      expect(order.paid, 100);
      expect(order.change, 0);
    });

    test('OrderObject legacy paid hydrates cash PaymentIntent', () {
      final order = OrderObject(
        createdAt: DateTime(2024, 1, 1),
        paid: 50,
        price: 45,
      );
      expect(order.payments, [
        const PaymentIntent(amount: 50, method: PaymentMethod.cash),
      ]);
      expect(order.paid, 50);
    });

    test('OrderObject toMap/fromMap round-trips payments and totalTax', () {
      final original = OrderObject(
        id: 1,
        createdAt: DateTime(2024, 1, 1),
        price: 120,
        totalTax: 20,
        payments: const [
          PaymentIntent(amount: 50, method: PaymentMethod.cash),
          PaymentIntent(amount: 70, method: PaymentMethod.card),
        ],
      );
      final map = original.toMap();
      expect(map['paid'], 120);
      expect(map['totalTax'], 20);
      expect(jsonDecode(map['payments'] as String), [
        {'amount': 50, 'method': 'cash'},
        {'amount': 70, 'method': 'card'},
      ]);

      final restored = OrderObject.fromMap({
        ...map,
        'id': 1,
        'createdAt': map['createdAt'],
      }, const []);
      expect(restored.paid, 120);
      expect(restored.totalTax, 20);
      expect(restored.payments, original.payments);
    });

    test('OrderObject.fromMap falls back to legacy paid column', () {
      final restored = OrderObject.fromMap({
        'id': 2,
        'paid': 33,
        'price': 30,
        'cost': 0,
        'productsPrice': 30,
        'productsCount': 1,
        'createdAt': 0,
      }, const []);
      expect(restored.payments, [
        const PaymentIntent(amount: 33, method: PaymentMethod.cash),
      ]);
    });

    test('OrderProductObject snapshots taxRate', () {
      const product = OrderProductObject(
        count: 2,
        singlePrice: 50,
        taxRate: 20,
      );
      expect(product.totalTax, 20);
      expect(product.toMap()['taxRate'], 20);
    });
  });
}
