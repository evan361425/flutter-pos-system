import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/stock/ingredient.dart';

import '../../mocks/mock_models.mocks.dart';
import '../../mocks/mock_repos.dart';
import '../../mocks/mock_storage.dart';

void main() {
  group('factory', () {
    test('#construct', () {
      final ingredient = ProductIngredient(id: '123');

      expect(ingredient.isEmpty, isTrue);
      expect(ingredient.amount, equals(0));
      expect(ingredient.id, equals('123'));
    });

    test('#fromObject', () {
      LOG_LEVEL = 2;
      final ingredient = ProductIngredient.fromObject(
          ProductIngredientObject.build(<String, Object?>{
        'id': 'ing-1',
        'ingredientId': 'ing-1',
        'amount': 2,
        'quantities': <String, Object?>{
          'quantity_1': <String, Object?>{
            'amount': 3,
            'quantityId': 'qua-1',
            'additionalPrice': 5,
            'additionalCost': 2,
          },
          // version 1
          'quantity_2': <String, Object?>{
            'amount': 3,
            'additionalPrice': 5,
            'additionalCost': 2,
          },
        },
      }));
      final isSame =
          ingredient.items.every((e) => identical(e.ingredient, ingredient));

      expect(isSame, isTrue);
      expect(ingredient.id, equals('ing-1'));
      expect(ingredient.amount, equals(2));
      expect(ingredient.length, equals(2));
      expect(ingredient.items.first.id, equals('quantity_1'));
    });

    test('#toObject', () {
      final ing = MockIngredient();
      final ingredient = ProductIngredient(id: 'ing-1', ingredient: ing);
      ingredient.ingredient = ing;
      when(ing.id).thenReturn('i-1');
      // when(ing.name).thenReturn('i-1');

      final object = ingredient.toObject();

      expect(object.id, equals(ingredient.id));
      expect(object.ingredientId, equals(ing.id));
      expect(object.amount, equals(ingredient.amount));
    });
  });

  group('Methods With Storage', () {
    late ProductIngredient ingredient;
    late MockProduct product;

    test('#remove', () async {
      LOG_LEVEL = 2;
      final expected = {ingredient.prefix: null};

      await ingredient.remove();

      verify(storage.set(any, argThat(equals(expected))));
      verify(product.removeItem(any));
    });

    group('#update', () {
      test('should not notify or update if not changed', () async {
        final object = ProductIngredientObject(amount: 1, ingredientId: 'i-1');

        await ingredient.update(object);

        verifyNever(storage.set(any, any));
        verifyNever(product.setItem(any));
      });

      test('update correctly', () async {
        final ing = MockIngredient();
        final object = ProductIngredientObject(amount: 2, ingredientId: 'i-2');
        when(ing.id).thenReturn('i-2');
        when(stock.getItem('i-2')).thenReturn(ing);
        // for logging
        LOG_LEVEL = 2;
        when(ing.name).thenReturn('ing-2');

        await ingredient.update(object);

        // after update, ingredient id will changed
        expect(identical(ingredient.ingredient, ing), isTrue);

        final prefix = ingredient.prefix;
        verify(storage.set(
            any,
            argThat(equals({
              '$prefix.amount': 2,
              '$prefix.ingredientId': 'i-2',
            }))));
      });
    });

    group('#setItem', () {
      test('should not add, but notify', () async {
        final ingredient = ProductIngredient(
          quantities: {'id': MockProductQuantity()},
          product: product,
        );
        final quantity = MockProductQuantity();
        when(quantity.id).thenReturn('id');

        await ingredient.setItem(quantity);

        verifyNever(storage.set(any, any));
        verify(product.setItem(any));
      });

      test('should add and notify', () async {
        LOG_LEVEL = 2;
        final quantity = MockProductQuantity();
        final ingredient = ProductIngredient(
          quantities: {'id1': MockProductQuantity()},
          product: product,
        );
        final object = MockProductQuantityObject();
        when(quantity.id).thenReturn('id2');
        when(quantity.prefix).thenReturn('hola');
        when(quantity.logCode).thenReturn('');
        when(quantity.toObject()).thenReturn(object);
        when(object.toMap()).thenReturn({'a': 'b'});

        await ingredient.setItem(quantity);

        verify(storage.set(
          any,
          argThat(equals({
            'hola': {'a': 'b'}
          })),
        ));
        verify(product.setItem(any));
      });
    });

    setUp(() {
      product = MockProduct();
      when(product.prefix).thenReturn('c_id.p_id');
      ingredient = ProductIngredient(
        id: 'ing-1',
        amount: 1,
        ingredient: Ingredient(name: 'ing-1', id: 'i-1'),
        product: product,
      );
    });
  });

  setUpAll(() {
    initializeRepos();
    initializeStorage();
  });
}
