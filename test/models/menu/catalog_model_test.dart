import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/helper/logger.dart';
import 'package:possystem/models/menu/catalog_model.dart';
import 'package:possystem/models/menu/product_model.dart';
import 'package:possystem/models/objects/menu_object.dart';

import '../../mocks/mock_objects.dart';
import '../../mocks/mock_storage.dart' as storage;
import '../../mocks/mock_menu.dart' as menu;
import '../../helpers/check_notifier.dart';

void main() {
  group('factory', () {
    test('#construct', () {
      final catalog = CatalogModel(index: 0, name: 'name');

      expect(catalog.createdDate, isNotNull);
      expect(catalog.products, equals({}));
      expect(catalog.id, isNotNull);
      expect(catalog.index, equals(0));
      expect(catalog.name, equals('name'));
    });

    test('#build', () {
      final catalog = CatalogModel.fromObject(mockCatalogObject);
      final isSame = catalog.products.values
          .every((product) => identical(product.catalog, catalog));

      expect(isSame, isTrue);
    });

    test('#toObject', () {
      final catalog = CatalogModel.fromObject(mockCatalogObject);
      final object = catalog.toObject();

      expect(identical(object, mockCatalogObject), isFalse);
      expect(object.name, equals(catalog.name));
      expect(object.index, equals(catalog.index));
      expect(object.id, equals(catalog.id));
      expect(object.createdAt, equals(catalog.createdAt));
      expect(object.products, isNotEmpty);
    });
  });

  group('Methods Without Storage', () {
    test('#newIndex', () {
      final catalog = CatalogModel(name: 'name', index: 100, products: {
        'id1': ProductModel(index: 1, name: '1'),
        'id2': ProductModel(index: 2, name: '2'),
        // id3 is been deleted
        'id4': ProductModel(index: 4, name: '4'),
      });

      expect(catalog.isEmpty, isFalse);
      expect(catalog.isNotEmpty, isTrue);
      expect(catalog.length, 3);
      expect(catalog.newIndex, 5);
    });

    test('#productList', () {
      final catalog = CatalogModel(name: 'name', index: 100, products: {
        'id1': ProductModel(index: 4, name: '1'),
        'id2': ProductModel(index: 2, name: '2'),
        'id4': ProductModel(index: 1, name: '4'),
      });
      final list = catalog.productList;

      expect(list[0].name, equals('4'));
      expect(list[1].name, equals('2'));
      expect(list[2].name, equals('1'));
    });

    test('#exist', () {
      final catalog = CatalogModel(name: 'name', index: 100, products: {
        'id1': ProductModel(index: 1, name: '1'),
      });

      expect(catalog.exist('id1'), isTrue);
      expect(catalog.exist('id2'), isFalse);
    });

    test('#getProduct', () {
      final catalog = CatalogModel(name: 'name', index: 100, products: {
        'id1': ProductModel(index: 1, name: '1'),
      });

      expect(catalog.getProduct('id1')?.name, equals('1'));
      expect(catalog.getProduct('id2'), isNull);
    });

    test('#removeProduct', () {
      final catalog = CatalogModel(name: 'name', index: 100, products: {
        'id1': ProductModel(index: 1, name: '1'),
      });

      final bool isCalled =
          checkNotifierCalled(catalog, () => catalog.removeProduct('id1'));

      expect(isCalled, isTrue);
      expect(catalog.isEmpty, isTrue);
    });
  });

  group('Methods With Storage', () {
    late CatalogModel catalog;
    test('#remove', () async {
      LOG_LEVEL = 2;

      await catalog.remove();

      verify(storage.mock.set(any, argThat(equals({'uuid': null}))));
      verify(menu.mock.removeCatalog('uuid'));
    });

    test('#reorderProducts', () async {
      final products = <ProductModel>[
        ProductModel(index: 3, name: '3', id: '3', catalog: catalog),
        ProductModel(index: 1, name: '1', id: '1', catalog: catalog),
        ProductModel(index: 2, name: '2', id: '2', catalog: catalog),
        ProductModel(index: 4, name: '4', id: '4', catalog: catalog),
      ];

      final bool isCalled = await checkNotifierCalled(
          catalog, () => catalog.reorderProducts(products));

      verify(storage.mock.set(
        any,
        argThat(equals({
          '${products[0].prefix}.index': 1,
          '${products[1].prefix}.index': 2,
          '${products[2].prefix}.index': 3,
        })),
      ));
      expect(isCalled, isTrue);
    });

    group('#update', () {
      test('should not notify or update if not changed', () async {
        final object = CatalogObject(name: 'name');

        final bool isCalled =
            await checkNotifierCalled(catalog, () => catalog.update(object));

        verifyNever(storage.mock.set(any, any));
        expect(isCalled, isFalse);
      });

      test('should notify and update', () async {
        final object = CatalogObject(name: 'new-name');

        final bool isCalled =
            await checkNotifierCalled(catalog, () => catalog.update(object));

        verify(storage.mock.set(
          any,
          argThat(equals({'${catalog.prefix}.name': 'new-name'})),
        ));
        expect(isCalled, isTrue);
      });
    });

    group('#setProduct', () {
      test('should not add, but notify', () async {
        final catalog = CatalogModel.fromObject(mockCatalogObject);
        final product = ProductModel(
            index: 1, name: 'name', id: 'product_1', catalog: catalog);

        final bool isCalled = await checkNotifierCalled(
            catalog, () => catalog.setProduct(product));

        verifyNever(storage.mock.set(any, any));
        expect(isCalled, isTrue);
      });

      test('should add and notify', () async {
        final catalog = CatalogModel.fromObject(mockCatalogObject);
        final product = ProductModel(
            index: 1, name: 'name', id: 'product_2', catalog: catalog);

        final bool isCalled = await checkNotifierCalled(
            catalog, () => catalog.setProduct(product));

        verify(storage.mock.set(any, argThat(isNot(containsValue(null)))));
        expect(isCalled, isTrue);
      });
    });

    setUp(() {
      catalog = CatalogModel(index: 1, name: 'name', id: 'uuid');
      storage.before();
      menu.before();
    });

    tearDown(() {
      storage.after();
      menu.after();
    });
  });
}
