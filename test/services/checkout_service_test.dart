import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/order/cart_product.dart';
import 'package:possystem/models/order/payment_intent.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/services/cart/cart_state.dart';
import 'package:possystem/services/cart/checkout_service.dart';

void main() {
  group('CheckoutCashMath', () {
    test('card overpayment is tip, not change', () {
      const payments = [PaymentIntent(amount: 100, method: PaymentMethod.card)];
      expect(CheckoutCashMath.change(payments: payments, grandTotal: 80), 0);
      expect(CheckoutCashMath.cashDue(payments: payments, grandTotal: 80), 0);
    });

    test('mixed tender: change only from cash above cashDue', () {
      const payments = [
        PaymentIntent(amount: 50, method: PaymentMethod.card),
        PaymentIntent(amount: 50, method: PaymentMethod.cash),
      ];
      // Bill 80 → after card 50, cashDue=30 → change = 50-30 = 20
      expect(CheckoutCashMath.cashDue(payments: payments, grandTotal: 80), 30);
      expect(CheckoutCashMath.change(payments: payments, grandTotal: 80), 20);
    });
  });

  group('CartState tax', () {
    test('totalTax and grand total include product taxRate', () {
      OrderAttributes();
      final product = Product(
        id: 'p-1',
        name: 'Coffee',
        price: 100,
        cost: 10,
        taxRate: 20,
      );
      Catalog(
        id: 'c-1',
        name: 'Drinks',
        products: {'p-1': product},
      ).prepareItem();

      final state = CartState();
      state.products.add(CartProduct(product, count: 2));

      expect(state.subtotal, 200);
      expect(state.totalTax, 40);
      expect(state.price, 240);
    });
  });

  group('CheckoutService', () {
    late List<OrderObject> pushed;
    late List<OrderObject> stocked;
    late List<MapEntry<Object, String>> enqueued;
    late List<List<num>> cashierCalls;
    late CheckoutService service;

    setUp(() {
      OrderAttributes();
      pushed = <OrderObject>[];
      stocked = <OrderObject>[];
      enqueued = <MapEntry<Object, String>>[];
      cashierCalls = <List<num>>[];

      service = CheckoutService.forTest(
        pushOrder: (order) async => pushed.add(order),
        stockOrder: (order) async => stocked.add(order),
        cashierPaid: (paid, price) async {
          cashierCalls.add([paid, price]);
          return CashierUpdateStatus.ok;
        },
        enqueue: (payload, endpoint) async {
          enqueued.add(MapEntry(payload, endpoint));
          return 1;
        },
      );
    });

    CartState _nonEmptyCart({num price = 50, num taxRate = 0}) {
      final product = Product(
        id: 'p-1',
        name: 'Coffee',
        price: price,
        cost: 10,
        taxRate: taxRate,
      );
      Catalog(
        id: 'c-1',
        name: 'Drinks',
        products: {'p-1': product},
      ).prepareItem();

      final state = CartState(name: 'test-cart');
      state.products.add(CartProduct(product));
      return state;
    }

    List<PaymentIntent> _cash(num amount) => [
      PaymentIntent(amount: amount, method: PaymentMethod.cash),
    ];

    test(
      'checkout returns CheckoutStatus.ok when dependencies succeed',
      () async {
        final state = _nonEmptyCart(price: 50);

        final status = await service.checkout(
          state: state,
          payments: _cash(50),
        );

        expect(status, CheckoutStatus.ok);
        expect(pushed, hasLength(1));
        expect(stocked, hasLength(1));
        expect(pushed.first.price, 50);
        expect(pushed.first.paid, 50);
        expect(pushed.first.payments.single.method, PaymentMethod.cash);
        expect(state.isEmpty, isTrue);
        expect(cashierCalls, [
          [50, 50],
        ]);
      },
    );

    test('checkout enqueues order payload to sync outbox', () async {
      final state = _nonEmptyCart(price: 20);

      await service.checkout(state: state, payments: _cash(20));
      await Future<void>.delayed(Duration.zero);

      expect(enqueued, hasLength(1));
      expect(enqueued.single.value, 'orders');
      expect(enqueued.single.key, isA<Map<String, Object?>>());
    });

    test('checkout returns nothingHappened when cart is empty', () async {
      final state = CartState(name: 'empty');

      final status = await service.checkout(state: state, payments: _cash(100));

      expect(status, CheckoutStatus.nothingHappened);
      expect(pushed, isEmpty);
      expect(enqueued, isEmpty);
    });

    test('checkout returns paidNotEnough when paid is below price', () async {
      final state = _nonEmptyCart(price: 50);

      final status = await service.checkout(state: state, payments: _cash(10));

      expect(status, CheckoutStatus.paidNotEnough);
      expect(pushed, isEmpty);
      expect(state.isEmpty, isFalse);
    });

    test('card-only checkout skips cash drawer mutation', () async {
      final state = _nonEmptyCart(price: 80);

      final status = await service.checkout(
        state: state,
        payments: const [
          PaymentIntent(amount: 100, method: PaymentMethod.card),
        ],
      );

      expect(status, CheckoutStatus.ok);
      expect(cashierCalls, isEmpty);
      expect(pushed.first.payments.single.method, PaymentMethod.card);
      expect(pushed.first.paid, 100);
    });

    test(
      'mixed payment: cashier sees only cashDue against cash tender',
      () async {
        final state = _nonEmptyCart(price: 80);

        final status = await service.checkout(
          state: state,
          payments: const [
            PaymentIntent(amount: 50, method: PaymentMethod.card),
            PaymentIntent(amount: 50, method: PaymentMethod.cash),
          ],
        );

        expect(status, CheckoutStatus.ok);
        // cashDue = 80-50 = 30, cash given = 50 → change 20 from drawer
        expect(cashierCalls, [
          [50, 30],
        ]);
      },
    );

    test('checkout persists totalTax on order', () async {
      final state = _nonEmptyCart(price: 100, taxRate: 10);

      await service.checkout(state: state, payments: _cash(110));

      expect(pushed.first.totalTax, 10);
      expect(pushed.first.price, 110);
    });
  });
}
