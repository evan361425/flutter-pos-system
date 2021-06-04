import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/models/menu/catalog_model.dart';

void main() {
  group('factory', () {
    test('construct with default property', () {
      final catalog = CatalogModel(index: 0, name: 'some-name');

      expect(catalog.createdAt, isNotNull);
      expect(catalog.products, equals({}));
      expect(catalog.id, isNotNull);
      expect(catalog.index, equals(0));
      expect(catalog.name, equals('some-name'));
    });
  });
}
