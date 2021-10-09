import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/stock/quantity.dart';

import '../../mocks/mock_repos.dart';
import '../../mocks/mock_storage.dart';

void main() {
  test('#fromObject', () {
    final object = QuantityObject(
      id: 'id',
      name: 'name',
      defaultProportion: 1.0,
    );
    final quantity = Quantity.fromObject(object);
    final newObject = quantity.toObject();

    expect(quantity.id, equals(object.id));
    expect(quantity.name, equals(object.name));
    expect(quantity.defaultProportion, equals(object.defaultProportion));
    expect(identical(quantity.toObject(), object), isFalse);
    expect(newObject.toMap(), equals(object.toMap()));
  });

  test('#getSimilarity', () {
    final quantity = Quantity(name: 'some-name', id: 'id');

    expect(quantity.getSimilarity('am'), greaterThan(0));
    expect(quantity.getSimilarity('om'), greaterThan(0));
    expect(quantity.getSimilarity('me'), greaterThan(0));
  });

  group('Methods With Storage', () {
    test('#remove', () async {
      LOG_LEVEL = 2;
      final quantity = Quantity(name: 'name', id: 'id');
      final expected = {quantity.prefix: null};

      await quantity.remove();

      verify(storage.set(any, argThat(equals(expected))));
      verify(quantities.removeItem(argThat(equals('id'))));
    });

    group('#update', () {
      test('should not notify or update if not changed', () async {
        final quantity =
            Quantity(name: 'name', id: 'id', defaultProportion: 1.0);
        final object = QuantityObject(name: 'name', defaultProportion: 1.0);

        await quantity.update(object);

        verifyNever(storage.set(any, any));
      });

      test('update without changing ingredient', () async {
        LOG_LEVEL = 2;
        final quantity =
            Quantity(name: 'name', id: 'id', defaultProportion: 1.0);
        final object = QuantityObject(name: 'name2', defaultProportion: 2.0);

        // Action
        await quantity.update(object);

        final prefix = quantity.prefix;
        final expected = {
          '$prefix.name': 'name2',
          '$prefix.defaultProportion': 2.0,
        };

        verify(storage.set(any, argThat(equals(expected))));
      });
    });
  });

  setUpAll(() {
    initializeRepos();
    initializeStorage();
  });
}
