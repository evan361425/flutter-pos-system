import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/stock/ingredient.dart';

import '../../mocks/mock_models.mocks.dart';
import '../../mocks/mock_objects.dart';
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

    test('#build', () {
      final object = mockCatalogObject.products.first.ingredients.first;
      final ingredient = ProductIngredient.fromObject(object);
      final isSame =
          ingredient.items.every((e) => identical(e.ingredient, ingredient));

      expect(isSame, isTrue);
      expect(ingredient.id, equals(object.id));
      expect(ingredient.amount, equals(object.amount));
    });

    test('#toObject', () {
      final origin = mockCatalogObject.products.first.ingredients.first;
      final ingredient = ProductIngredient.fromObject(origin);
      final object = ingredient.toObject();

      expect(identical(object, origin), isFalse);
      expect(object.id, equals(ingredient.id));
      expect(object.amount, equals(ingredient.amount));
      expect(object.quantities, isNotEmpty);
    });
  });

  group('Methods Without Storage', () {
    test('#prefix', () {
      final product = MockProduct();
      final ingredient = ProductIngredient(product: product, id: 'ing_1');
      when(product.prefix).thenReturn('prefix');

      expect(ingredient.prefix, contains('prefix'));
      expect(ingredient.prefix, contains('ing_1'));
    });

    test('#exist', () {
      final ingredient = ProductIngredient(quantities: {
        'id1': MockProductQuantity(),
      });

      expect(ingredient.hasItem('id1'), isTrue);
      expect(ingredient.hasItem('id2'), isFalse);
    });

    test('#getQuantity', () {
      final quantity = MockProductQuantity();
      final ingredient = ProductIngredient(quantities: {'id1': quantity});

      expect(identical(ingredient.getItem('id1'), quantity), isTrue);
      expect(ingredient.getItem('id2'), isNull);
    });

    test('#removeQuantity', () {
      final product = MockProduct();
      final ingredient = ProductIngredient(quantities: {
        'id1': MockProductQuantity(),
      }, product: product);

      ingredient.removeItem('id1');

      expect(ingredient.items, isEmpty);
      // product must be notified
      verify(product.setItem(ingredient));
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
        final object = ProductIngredientObject(amount: 1, id: 'i_id');

        await ingredient.update(object);

        verifyNever(storage.set(any, any));
        verifyNever(product.setItem(any));
      });

      test('update without changing ingredient', () async {
        LOG_LEVEL = 2;
        final object = ProductIngredientObject(amount: 2, id: 'i_id');
        when(product.setItem(any)).thenAnswer((_) => Future.value());

        await ingredient.update(object);

        // after update, ingredient id will changed
        final prefix = ingredient.prefix;

        verify(storage.set(any, argThat(equals({'$prefix.amount': 2}))));
      });

      test('#changeIngredient, #remove, #setIngredient', () async {
        LOG_LEVEL = 2;
        final object = ProductIngredientObject(amount: 2, id: 'i_id2');
        final oldPrefix = ingredient.prefix;
        final newIngredient = Ingredient(name: 'ing', id: 'i_id2');
        when(stock.getItem('i_id2')).thenReturn(newIngredient);

        await ingredient.update(object);

        verifyInOrder([
          storage.set(any, argThat(equals({oldPrefix: null}))),
          product.removeItem(argThat(equals('i_id'))),
          product.setItem(any),
        ]);
        identical(ingredient.ingredient, newIngredient);
        expect(ingredient.id, equals('i_id2'));
      });
    });

    group('#setQuantity', () {
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
        amount: 1,
        ingredient: Ingredient(name: 'ing', id: 'i_id'),
        product: product,
      );
    });
  });

  setUpAll(() {
    initializeRepos();
    initializeStorage();
  });
}
