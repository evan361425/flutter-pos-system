import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/stock/quantity.dart';

import '../../mocks/mock_models.mocks.dart';
import '../../mocks/mock_repos.dart';
import '../../mocks/mock_storage.dart';

void main() {
  group('factory', () {
    test('#construct', () {
      final quantity = ProductQuantity(
          amount: 1, additionalCost: 2, additionalPrice: 3, id: '123');

      expect(quantity.id, equals('123'));
      expect(quantity.amount, equals(1));
      expect(quantity.additionalCost, equals(2));
      expect(quantity.additionalPrice, equals(3));
    });

    test('#fromObject', () {
      final quantity = ProductQuantity.fromObject(ProductQuantityObject.build({
        'id': 'qua-1',
        'quantityId': 'q-1',
        'amount': 3,
        'additionalPrice': 5,
        'additionalCost': 2,
      }));

      expect(quantity.id, equals('qua-1'));
      expect(quantity.amount, equals(3));
      expect(quantity.additionalCost, equals(2));
      expect(quantity.additionalPrice, equals(5));
    });

    test('#toObject', () {
      final qua = MockQuantity();
      when(qua.id).thenReturn('q-1');
      final quantity = ProductQuantity(
        id: 'qua-1',
        quantity: qua,
        amount: 3,
        additionalPrice: 5,
        additionalCost: 2,
      );
      final object = quantity.toObject();

      expect(quantity.id, equals(object.id));
      expect(qua.id, equals(object.quantityId));
      expect(quantity.amount, equals(object.amount));
      expect(quantity.additionalCost, equals(object.additionalCost));
      expect(quantity.additionalPrice, equals(object.additionalPrice));
    });
  });

  group('Methods With Storage', () {
    late ProductQuantity quantity;
    late MockProductIngredient ingredient;

    test('#remove', () async {
      LOG_LEVEL = 2;
      final expected = {quantity.prefix: null};

      await quantity.remove();

      verify(storage.set(any, argThat(equals(expected))));
      verify(ingredient.removeItem(any));
    });

    group('#update', () {
      test('should not notify or update if not changed', () async {
        final object = ProductQuantityObject(
            amount: 1, additionalCost: 2, additionalPrice: 3);

        await quantity.update(object);

        verifyNever(storage.set(any, any));
        verifyNever(ingredient.setItem(any));
      });

      test('update correctly', () async {
        final qua = MockQuantity();
        final object = ProductQuantityObject(
            quantityId: 'q-1',
            amount: 2,
            additionalCost: 3,
            additionalPrice: 4);
        when(qua.id).thenReturn('q-1');
        when(quantities.getItem('q-1')).thenReturn(qua);
        // for logging
        LOG_LEVEL = 2;
        when(qua.name).thenReturn('q-1');

        await quantity.update(object);

        expect(identical(quantity.quantity, qua), isTrue);

        final prefix = quantity.prefix;
        final expected = {
          '$prefix.quantityId': 'q-1',
          '$prefix.amount': 2,
          '$prefix.additionalCost': 3,
          '$prefix.additionalPrice': 4,
        };
        verify(storage.set(any, argThat(equals(expected))));
      });
    });

    setUp(() {
      ingredient = MockProductIngredient();
      quantity = ProductQuantity(
          amount: 1,
          additionalCost: 2,
          additionalPrice: 3,
          ingredient: ingredient,
          quantity: Quantity(name: 'qua', id: 'q_id'));

      when(ingredient.prefix).thenReturn('i_prefix');
      when(ingredient.name).thenReturn('i_name');
    });
  });

  setUpAll(() {
    initializeRepos();
    initializeStorage();
  });
}
