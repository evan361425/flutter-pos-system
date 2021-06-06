import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/menu/product_ingredient_model.dart';
import 'package:possystem/models/menu/product_model.dart';
import 'package:possystem/models/menu/product_quantity_model.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/stock/ingredient_model.dart';

import '../../mocks/mock_objects.dart';
import '../../mocks/mock_storage.dart' as storage;
import '../../mocks/mock_stock.dart' as stock;
import 'product_ingredient_model_test.mocks.dart';

@GenerateMocks([ProductModel, ProductQuantityModel, ProductQuantityObject])
void main() {
  group('factory', () {
    test('#construct', () {
      final ingredient = ProductIngredientModel(id: '123');

      expect(ingredient.quantities, equals({}));
      expect(ingredient.amount, equals(0));
      expect(ingredient.id, equals('123'));
    });

    test('#build', () {
      final object = mockCatalogObject.products.first.ingredients.first;
      final ingredient = ProductIngredientModel.fromObject(object);
      final isSame = ingredient.quantities.values
          .every((e) => identical(e.ingredient, ingredient));

      expect(isSame, isTrue);
      expect(ingredient.id, equals(object.id));
      expect(ingredient.amount, equals(object.amount));
    });

    test('#toObject', () {
      final origin = mockCatalogObject.products.first.ingredients.first;
      final ingredient = ProductIngredientModel.fromObject(origin);
      final object = ingredient.toObject();

      expect(identical(object, origin), isFalse);
      expect(object.id, equals(ingredient.id));
      expect(object.amount, equals(ingredient.amount));
      expect(object.quantities, isNotEmpty);
    });
  });

  group('Methods Without Storage', () {
    test('#prefix', () {
      final product = MockProductModel();
      final ingredient = ProductIngredientModel(product: product, id: 'ing_1');
      when(product.prefix).thenReturn('prefix');

      expect(ingredient.prefix, contains('prefix'));
      expect(ingredient.prefix, contains('ing_1'));
    });

    test('#exist', () {
      final ingredient = ProductIngredientModel(quantities: {
        'id1': MockProductQuantityModel(),
      });

      expect(ingredient.exist('id1'), isTrue);
      expect(ingredient.exist('id2'), isFalse);
    });

    test('#getQuantity', () {
      final quantity = MockProductQuantityModel();
      final ingredient = ProductIngredientModel(quantities: {'id1': quantity});

      expect(identical(ingredient.getQuantity('id1'), quantity), isTrue);
      expect(ingredient.getQuantity('id2'), isNull);
    });

    test('#removeQuantity', () {
      final product = MockProductModel();
      final ingredient = ProductIngredientModel(quantities: {
        'id1': MockProductQuantityModel(),
      }, product: product);

      ingredient.removeQuantity('id1');

      expect(ingredient.quantities, isEmpty);
      // product must be notified
      verify(product.setIngredient(ingredient));
    });
  });

  group('Methods With Storage', () {
    late ProductIngredientModel ingredient;
    late MockProductModel product;

    test('#remove', () async {
      LOG_LEVEL = 2;
      final expected = {ingredient.prefix: null};

      await ingredient.remove();

      verify(storage.mock.set(any, argThat(equals(expected))));
      verify(product.removeIngredient(any));
    });

    group('#update', () {
      test('should not notify or update if not changed', () async {
        final object = ProductIngredientObject(amount: 1, id: 'i_id');

        await ingredient.update(object);

        verifyNever(storage.mock.set(any, any));
        verifyNever(product.setIngredient(any));
      });

      test('update without changing ingredient', () async {
        LOG_LEVEL = 2;
        final object = ProductIngredientObject(amount: 2, id: 'i_id');

        await ingredient.update(object);

        // after update, ingredient id will changed
        final prefix = ingredient.prefix;

        verify(storage.mock.set(any, argThat(equals({'$prefix.amount': 2}))));
      });

      test('#changeIngredient, #remove, #setIngredient', () async {
        LOG_LEVEL = 2;
        final object = ProductIngredientObject(amount: 2, id: 'i_id2');
        final oldPrefix = ingredient.prefix;
        final newIngredient = IngredientModel(name: 'ing', id: 'i_id2');
        when(stock.mock.getIngredient('i_id2')).thenReturn(newIngredient);

        await ingredient.update(object);

        verifyInOrder([
          storage.mock.set(any, argThat(equals({oldPrefix: null}))),
          product.removeIngredient(argThat(equals('i_id'))),
          product.setIngredient(any),
        ]);
        identical(ingredient.ingredient, newIngredient);
        expect(ingredient.id, equals('i_id2'));
      });
    });

    group('#setQuantity', () {
      test('should not add, but notify', () async {
        final ingredient = ProductIngredientModel(
          quantities: {'id': MockProductQuantityModel()},
          product: product,
        );
        final quantity = MockProductQuantityModel();
        when(quantity.id).thenReturn('id');

        await ingredient.setQuantity(quantity);

        verifyNever(storage.mock.set(any, any));
        verify(product.setIngredient(any));
      });

      test('should add and notify', () async {
        LOG_LEVEL = 2;
        final quantity = MockProductQuantityModel();
        final ingredient = ProductIngredientModel(
          quantities: {'id1': MockProductQuantityModel()},
          product: product,
        );
        final object = MockProductQuantityObject();
        when(quantity.id).thenReturn('id2');
        when(quantity.prefix).thenReturn('hola');
        when(quantity.toString()).thenReturn('hola');
        when(quantity.toObject()).thenReturn(object);
        when(object.toMap()).thenReturn({'a': 'b'});

        await ingredient.setQuantity(quantity);

        verify(storage.mock.set(
          any,
          argThat(equals({
            'hola': {'a': 'b'}
          })),
        ));
        verify(product.setIngredient(any));
      });
    });

    setUp(() {
      product = MockProductModel();
      when(product.ingredients).thenReturn({});
      when(product.prefix).thenReturn('c_id.p_id');
      when(product.toString()).thenReturn('cat.pro');
      ingredient = ProductIngredientModel(
        amount: 1,
        ingredient: IngredientModel(name: 'ing', id: 'i_id'),
        product: product,
      );
      storage.before();
      stock.before();
    });

    tearDown(() {
      storage.after();
      stock.after();
    });
  });
}
