import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:possystem/models/menu/catalog_model.dart';
import 'package:possystem/models/menu/product_model.dart';
import 'package:possystem/services/storage.dart';

import '../../helpers/mock_objects.dart';
import '../../helpers/check_notifier.dart';

@GenerateMocks([Storage])
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
    test('remove', () {});
  });
}
