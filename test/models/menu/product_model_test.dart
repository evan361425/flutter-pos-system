import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/menu/catalog_model.dart';
import 'package:possystem/models/menu/product_ingredient_model.dart';
import 'package:possystem/models/menu/product_model.dart';
import 'package:possystem/models/menu/product_quantity_model.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/stock/ingredient_model.dart';

import '../../mocks/mock_objects.dart';
import '../../mocks/mocks.dart';
import '../../test_helpers/check_notifier.dart';
import '../../mocks/mockito/mock_catalog_model.dart';
import 'product_quantity_model_test.mocks.dart';

void main() {
  group('factory', () {
    test('#construct', () {
      final product = ProductModel(index: 0, name: 'name');

      expect(product.createdAt, isNotNull);
      expect(product.isEmpty, isTrue);
      expect(product.id, isNotNull);
      expect(product.index, equals(0));
      expect(product.name, equals('name'));
    });

    test('#build', () {
      final object = mockCatalogObject.products.first;
      final product = ProductModel.fromObject(object);
      final isSame = product.items.every((e) => identical(e.product, product));

      expect(isSame, isTrue);
      expect(object.id, product.id);
      expect(object.cost, product.cost);
      expect(object.index, product.index);
      expect(object.name, product.name);
    });

    test('#toObject', () {
      final product = ProductModel.fromObject(mockCatalogObject.products.first);
      final object = product.toObject();

      expect(identical(object, mockCatalogObject.products.first), isFalse);
      expect(object.name, equals(product.name));
      expect(object.index, equals(product.index));
      expect(object.id, equals(product.id));
      expect(object.cost, equals(product.cost));
      expect(object.price, equals(product.price));
      expect(object.createdAt, equals(product.createdAt));
      expect(object.ingredients, isNotEmpty);
    });
  });

  group('Methods Without Storage', () {
    test('#ingredientsWithQuantity', () {
      final product = ProductModel(index: 1, name: '', ingredients: {
        'ing_1': ProductIngredientModel(id: 'ing_1', quantities: {}),
        'ing_2': ProductIngredientModel(id: 'ing_2', quantities: {
          'qua_1': ProductQuantityModel(
              amount: 1, additionalCost: 1, additionalPrice: 1),
        }),
      });

      expect(product.ingredientsWithQuantity.first.id, equals('ing_2'));
    });

    test('#prefix', () {
      final catalog = CatalogModel(name: '', index: 1, id: 'cat_1');
      final product =
          ProductModel(index: 1, name: '', id: 'pro_1', catalog: catalog);

      expect(product.prefix, contains('cat_1'));
      expect(product.prefix, contains('pro_1'));
    });

    test('#exist', () {
      final product = ProductModel(name: 'name', index: 100, ingredients: {
        'id1': ProductIngredientModel(id: 'id1'),
      });

      expect(product.hasItem('id1'), isTrue);
      expect(product.hasItem('id2'), isFalse);
    });

    test('#getIngredient', () {
      final product = ProductModel(name: 'name', index: 100, ingredients: {
        'id1': ProductIngredientModel(id: 'id1'),
      });

      expect(product.getItem('id1')?.id, equals('id1'));
      expect(product.getItem('id2'), isNull);
    });

    test('#removeIngredient', () {
      final catalog = MockCatalogModel();
      final product = ProductModel(
          name: 'name',
          index: 100,
          catalog: catalog,
          ingredients: {
            'id1': MockProductIngredientModel(),
          });

      final bool isCalled =
          checkNotifierCalled(product, () => product.removeItem('id1'));

      verify(catalog.notifyListeners());
      expect(isCalled, isTrue);
      expect(product.isEmpty, isTrue);
    });
  });

  group('Methods With Storage', () {
    late ProductModel product;
    late MockCatalogModel catalog;

    test('#remove', () async {
      LOG_LEVEL = 2;
      final expected = {product.prefix: null};

      await product.remove();

      verify(storage.set(any, argThat(equals(expected))));
      verify(catalog.removeItem('p_id'));
    });

    group('#update', () {
      test('should not notify or update if not changed', () async {
        final object = ProductObject(name: 'name', cost: 1, price: 2);

        final bool isCalled =
            await checkNotifierCalled(product, () => product.update(object));

        verifyNever(storage.set(any, any));
        expect(isCalled, isFalse);
      });

      test('should notify and update', () async {
        LOG_LEVEL = 2;
        final object = ProductObject(name: 'new-name', cost: 2, price: 3);
        final prefix = product.prefix;

        final bool isCalled =
            await checkNotifierCalled(product, () => product.update(object));

        verify(storage.set(
          any,
          argThat(equals({
            '$prefix.name': 'new-name',
            '$prefix.cost': 2,
            '$prefix.price': 3,
          })),
        ));
        expect(isCalled, isTrue);
      });
    });

    group('#setIngredient', () {
      test('should not add, but notify', () async {
        final product =
            ProductModel.fromObject(mockCatalogObject.products.first);
        final ingredient = ProductIngredientModel(id: 'ingredient_1');
        product.catalog = catalog;

        final bool isCalled = await checkNotifierCalled(
            product, () => product.setItem(ingredient));

        verifyNever(storage.set(any, any));
        verify(catalog.notifyListeners());
        expect(isCalled, isTrue);
      });

      test('should add and notify', () async {
        LOG_LEVEL = 2;
        final product =
            ProductModel.fromObject(mockCatalogObject.products.first);
        final ingredient = ProductIngredientModel(
            ingredient: IngredientModel(name: 'hi', id: 'ingredient_3'),
            product: product);
        product.catalog = catalog;

        final bool isCalled = await checkNotifierCalled(
            product, () => product.setItem(ingredient));

        verify(storage.set(any, argThat(isNot(containsValue(null)))));
        verify(catalog.notifyListeners());
        expect(isCalled, isTrue);
      });
    });

    setUp(() {
      catalog = MockCatalogModel();
      when(catalog.name).thenReturn('');
      when(catalog.index).thenReturn(1);
      when(catalog.id).thenReturn('c_id');
      when(catalog.toString()).thenReturn('catalog_string');
      product = ProductModel(
        index: 1,
        name: 'name',
        id: 'p_id',
        cost: 1,
        price: 2,
        catalog: catalog,
      );
    });
  });

  setUpAll(() {
    initialize();
  });
}
