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

    ProductQuantityObject createObject() {
      return ProductQuantityObject.build({
        'id': 'qua-1',
        'amount': 3,
        'additionalPrice': 5,
        'additionalCost': 2,
      });
    }

    test('#fromObject', () {
      final quantity = ProductQuantity.fromObject(createObject());

      expect(quantity.id, equals('qua-1'));
      expect(quantity.amount, equals(3));
      expect(quantity.additionalCost, equals(2));
      expect(quantity.additionalPrice, equals(5));
    });

    test('#toObject', () {
      final origin = createObject();
      final quantity = ProductQuantity.fromObject(origin);
      final object = quantity.toObject();

      expect(identical(object, origin), isFalse);
      expect(quantity.id, equals(object.id));
      expect(quantity.amount, equals(object.amount));
      expect(quantity.additionalCost, equals(object.additionalCost));
      expect(quantity.additionalPrice, equals(object.additionalPrice));
    });
  });

  group('Methods Without Storage', () {
    test('#prefix', () {
      final ingredient = MockProductIngredient();
      final quantity = ProductQuantity(
          amount: 1,
          additionalCost: 2,
          additionalPrice: 3,
          id: '123',
          ingredient: ingredient);
      when(ingredient.prefix).thenReturn('prefix');
      // when(ingredient.ingredient).thenReturn();

      expect(quantity.prefix, contains('prefix'));
      expect(quantity.prefix, contains('123'));
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

      test('update without changing ingredient', () async {
        LOG_LEVEL = 2;
        final object = ProductQuantityObject(
            amount: 2, additionalCost: 3, additionalPrice: 4);

        await quantity.update(object);

        // after update, ingredient id will changed
        final prefix = quantity.prefix;
        final expected = {
          '$prefix.amount': 2,
          '$prefix.additionalCost': 3,
          '$prefix.additionalPrice': 4,
        };

        verify(storage.set(any, argThat(equals(expected))));
      });

      test('#changeIngredient, #remove, #setIngredient', () async {
        LOG_LEVEL = 2;
        final object = ProductQuantityObject(
            amount: 2, additionalCost: 3, additionalPrice: 4, id: 'q_id2');
        final newQuantity = Quantity(name: 'qua', id: 'q_id2');
        final oldPrefix = quantity.prefix;
        when(quantities.getItem('q_id2')).thenReturn(newQuantity);

        await quantity.update(object);

        verifyInOrder([
          storage.set(any, argThat(equals({oldPrefix: null}))),
          ingredient.removeItem(argThat(equals('q_id'))),
          ingredient.setItem(any),
        ]);
        identical(quantity.quantity, newQuantity);
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
