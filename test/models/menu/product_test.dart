import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/stock/ingredient.dart';

import '../../mocks/mock_models.mocks.dart';
import '../../mocks/mock_storage.dart';
import '../../test_helpers/check_notifier.dart';

void main() {
  Product createProduct([
    String name = 'product',
    List<String> ingredients = const ['i1'],
  ]) {
    return Product(
      id: name,
      name: name,
      ingredients: {
        for (var ingredient in ingredients)
          ingredient: ProductIngredient(
            ingredient: Ingredient(name: ingredient, id: ingredient),
          )
      },
    );
  }

  group('factory', () {
    test('#construct', () {
      final product = Product(index: 0, name: 'name');

      expect(product.createdAt, isNotNull);
      expect(product.isEmpty, isTrue);
      expect(product.id, isNotNull);
      expect(product.index, equals(0));
      expect(product.name, equals('name'));
    });

    test('#fromObject', () {
      final product = Product.fromObject(ProductObject.build(<String, Object?>{
        'id': 'product_1',
        'name': 'hame burger',
        'index': 1,
        'createdAt': 1623639573,
        'price': 1,
        'cost': 1,
        'ingredients': <String, Object?>{
          'ingredient_1': <String, Object?>{
            'id': 'ingredient_1',
            'amount': 1,
            'quantities': <String, Object?>{}
          },
          'ingredient_2': null,
        }
      }));
      final isSame = product.items.every((e) => identical(e.product, product));

      expect(isSame, isTrue);
      expect('product_1', equals(product.id));
      expect('hame burger', equals(product.name));
      expect(1, equals(product.cost));
      expect(1, equals(product.price));
      expect(1, equals(product.index));
    });

    test('#toObject', () {
      final product = createProduct();
      final object = product.toObject();

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
      final product = Product(index: 1, name: '', ingredients: {
        'ing_1': ProductIngredient(id: 'ing_1', quantities: {}),
        'ing_2': ProductIngredient(id: 'ing_2', quantities: {
          'qua_1':
              ProductQuantity(amount: 1, additionalCost: 1, additionalPrice: 1),
        }),
      });

      expect(product.ingredientsWithQuantity.first.id, equals('ing_2'));
    });

    test('#prefix', () {
      final catalog = Catalog(name: '', index: 1, id: 'cat_1');
      final product = Product(name: '', id: 'pro_1', catalog: catalog);

      expect(product.prefix, contains('cat_1'));
      expect(product.prefix, contains('pro_1'));
    });

    test('#getItemsSimilarity', () {
      final ing1 = MockProductIngredient();
      final ing2 = MockProductIngredient();
      final product = Product(
        name: 'pro',
        ingredients: {'ing1': ing1, 'ing2': ing2},
      );

      when(ing1.getSimilarity(any)).thenReturn(1);
      when(ing2.getSimilarity(any)).thenReturn(3);
      when(ing1.items).thenReturn([]);
      when(ing2.items).thenReturn([]);
      expect(product.getItemsSimilarity('pattern'), equals(3));

      final qua1 = MockProductQuantity();
      when(ing1.items).thenReturn(<ProductQuantity>[qua1]);
      when(qua1.getSimilarity(any)).thenReturn(5);

      expect(product.getItemsSimilarity('pattern'), equals(5));
    });
  });

  group('Methods With Storage', () {
    late Product product;
    late MockCatalog catalog;

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

    group('#setItem', () {
      test('should not add, but notify', () async {
        final product = createProduct('p', ['ingredient_1']);
        final ingredient = ProductIngredient(id: 'ingredient_1');
        product.catalog = catalog;

        final bool isCalled = await checkNotifierCalled(
            product, () => product.setItem(ingredient));

        verifyNever(storage.set(any, any));
        verify(catalog.notifyListeners());
        expect(isCalled, isTrue);
      });

      test('should add and notify', () async {
        LOG_LEVEL = 2;
        final product = createProduct('p', ['ingredient_1']);
        final ingredient = ProductIngredient(
            ingredient: Ingredient(name: 'hi', id: 'ingredient_2'),
            product: product);
        product.catalog = catalog;

        final bool isCalled = await checkNotifierCalled(
            product, () => product.setItem(ingredient));

        verify(storage.set(any, argThat(isNot(containsValue(null)))));
        verify(catalog.notifyListeners());
        expect(isCalled, isTrue);
      });
    });

    test('#searched', () {
      LOG_LEVEL = 2;
      final catalog = Catalog(name: 'cat', id: 'cat');
      final product = createProduct('pro');
      product.catalog = catalog;

      product.searched();

      verify(storage.set(
        any,
        argThat(predicate<Map<String, Object?>>(
            (map) => map['cat.products.pro.searchedAt'] != null)),
      ));
    });

    setUp(() {
      catalog = MockCatalog();
      when(catalog.prefix).thenReturn('');
      when(catalog.name).thenReturn('');
      when(catalog.index).thenReturn(1);
      when(catalog.id).thenReturn('c_id');
      product = Product(
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
    initializeStorage();
  });
}
