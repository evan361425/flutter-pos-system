import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/order/order_product.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/providers/currency_provider.dart';

import '../mocks/mock_cache.dart';
import '../mocks/mock_storage.dart';

void main() {
  group('Repository', () {
    group('Disposable', () {
      test('Cart', () {
        final cart = Cart();
        cart.products.add(OrderProduct(Product()));
        expect(cart.isEmpty, isFalse);
        cart.dispose();
        expect(cart.isEmpty, isTrue);
      });

      test('Cashier', () async {
        final currency = CurrencyProvider();
        when(cache.get(any)).thenReturn(null);
        when(cache.set(any, any)).thenAnswer((_) => Future.value(true));
        await currency.setCurrency(CurrencyTypes.TWD);
        final cashier = Cashier();

        // ignore: invalid_use_of_protected_member
        expect(currency.hasListeners, isTrue);

        cashier.dispose();
        // ignore: invalid_use_of_protected_member
        expect(currency.hasListeners, isFalse);
      });
    });

    group('Should catch error', () {
      test('Cart', () {
        expect(() => Cart().toggleAll(null, except: OrderProduct(Product())),
            throwsAssertionError);
      });

      test('Cashier', () async {
        final dirtyData = [
          {'count': '', 'unit': 2}
        ];
        CurrencyProvider().unitList = [1, 2, 3];

        final cashier = Cashier();
        await cashier.deleteFavorite(0);

        await cashier.setCurrent(dirtyData);
        verify(storage.add(any, any, any));

        when(storage.get(any, any)).thenAnswer((_) => Future.value({
              'default': dirtyData,
            }));
        await cashier.reset();

        await cashier.setFavorite(dirtyData);
      });
    });

    group('Cashier', () {
      test('findPossibleChange', () async {
        CurrencyProvider();
        final cashier = Cashier();
        await cashier.setCurrent([
          {'unit': 10},
          {'unit': 100},
          {'unit': 500},
        ]);

        // should same as docs
        var result = cashier.findPossibleChange(1, 100);
        expect(result!.count, equals(10));
        expect(result.unit, equals(10));

        result = cashier.findPossibleChange(1, 10);
        expect(result, isNull);

        result = cashier.findPossibleChange(6, 100)!;
        expect(result.count, equals(1));
        expect(result.unit, equals(500));

        result = cashier.findPossibleChange(4, 100)!;
        expect(result.count, equals(40));
        expect(result.unit, equals(10));

        result = cashier.findPossibleChange(9, 10);
        expect(result, isNull);
      });
    });

    setUpAll(() {
      LOG_LEVEL = 0;
      initializeCache();
      initializeStorage();
    });
  });
}
