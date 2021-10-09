import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/objects/menu_object.dart';

import '../../mocks/mock_models.mocks.dart';
import '../../mocks/mock_repos.dart';
import '../../mocks/mock_storage.dart';
import '../../test_helpers/check_notifier.dart';

void main() {
  Catalog createCatalog([
    String name = 'catalog',
    List<String> products = const ['p1'],
  ]) {
    return Catalog(
      id: name,
      name: name,
      products: {
        for (var product in products)
          product: Product(name: product, id: product)
      },
    );
  }

  group('factory', () {
    test('#construct', () {
      final catalog = Catalog(index: 0, name: 'name');

      expect(catalog.createdDate, isNotNull);
      expect(catalog.items, isEmpty);
      expect(catalog.id, isNotNull);
      expect(catalog.index, equals(0));
      expect(catalog.name, equals('name'));
    });

    test('#fromObject', () {
      final catalog = Catalog.fromObject(CatalogObject.build(<String, Object?>{
        'id': 'catalog_1',
        'name': 'burger',
        'index': 1,
        'createdAt': 1623639573,
        'products': <String, Object?>{
          'product_1': <String, Object?>{
            'name': 'ham burger',
            'index': 1,
            'price': 30,
            'cost': 10,
            'createdAt': 1623639573,
            'ingredients': <String, Object?>{}
          },
        }
      }));
      final isSame =
          catalog.items.every((product) => identical(product.catalog, catalog));

      expect(isSame, isTrue);
    });

    test('#toObject', () {
      final catalog = createCatalog();
      final object = catalog.toObject();

      expect(object.name, equals(catalog.name));
      expect(object.index, equals(catalog.index));
      expect(object.id, equals(catalog.id));
      expect(object.createdAt, equals(catalog.createdAt));
      expect(object.products, isNotEmpty);
    });
  });

  group('Methods Without Storage', () {
    test('#getItemsSimilarity', () {
      final p1 = MockProduct();
      final p2 = MockProduct();
      final catalog = Catalog(name: '', products: {'1': p1, '2': p2});

      // use product value and no consider ingredient
      when(p1.getSimilarity(any)).thenReturn(2);
      when(p2.getSimilarity(any)).thenReturn(0);
      when(p2.getItemsSimilarity(any)).thenReturn(2);
      final scores =
          catalog.getItemsSimilarity('pattern').map((e) => e.value).toList();

      expect(scores[0] > scores[1], isTrue);
      expect(scores[0], isNonZero);
      expect(scores[1], isNonZero);
      verifyNever(p1.getItemsSimilarity(any));
    });
  });

  group('Methods With Storage', () {
    late Catalog catalog;
    test('#remove', () async {
      LOG_LEVEL = 2;

      await catalog.remove();

      verify(storage.set(any, argThat(equals({'uuid': null}))));
      verify(menu.removeItem('uuid'));
    });

    test('#reorderItems', () async {
      final products = <Product>[
        Product(index: 3, name: '3', id: '3', catalog: catalog),
        Product(index: 1, name: '1', id: '1', catalog: catalog),
        Product(index: 2, name: '2', id: '2', catalog: catalog),
        Product(index: 4, name: '4', id: '4', catalog: catalog),
      ];

      final bool isCalled = await checkNotifierCalled(
          catalog, () => catalog.reorderItems(products));

      verify(storage.set(
        any,
        argThat(equals({
          '${products[0].prefix}.index': 1,
          '${products[1].prefix}.index': 2,
          '${products[2].prefix}.index': 3,
          '${products[3].prefix}.index': 4,
        })),
      ));
      expect(isCalled, isTrue);
    });

    group('#update', () {
      test('should not notify or update if not changed', () async {
        final object = CatalogObject(name: 'name');

        final bool isCalled =
            await checkNotifierCalled(catalog, () => catalog.update(object));

        verifyNever(storage.set(any, any));
        expect(isCalled, isFalse);
      });

      test('should notify and update', () async {
        LOG_LEVEL = 2;
        final object = CatalogObject(name: 'new-name');

        final bool isCalled =
            await checkNotifierCalled(catalog, () => catalog.update(object));

        verify(storage.set(
          any,
          argThat(equals({'${catalog.prefix}.name': 'new-name'})),
        ));
        expect(isCalled, isTrue);
      });
    });

    group('#setItem', () {
      test('should not add, but notify', () async {
        catalog = createCatalog('catalog-1', ['product-1']);
        final product =
            Product(name: 'product-1', id: 'product-1', catalog: catalog);

        final bool isCalled =
            await checkNotifierCalled(catalog, () => catalog.setItem(product));

        verifyNever(storage.set(any, any));
        expect(isCalled, isTrue);
      });

      test('should add and notify', () async {
        LOG_LEVEL = 2;
        catalog = createCatalog('catalog-1', ['product-1']);
        final product =
            Product(name: 'product-2', id: 'product-2', catalog: catalog);

        final bool isCalled =
            await checkNotifierCalled(catalog, () => catalog.setItem(product));

        verify(storage.set(any, argThat(isNot(containsValue(null)))));
        expect(isCalled, isTrue);
      });
    });

    setUp(() {
      catalog = Catalog(name: 'name', id: 'uuid');
    });
  });

  setUpAll(() {
    initializeRepos();
    initializeStorage();
  });
}
