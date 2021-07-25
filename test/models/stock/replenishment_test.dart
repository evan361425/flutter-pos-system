import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/stock/replenishment.dart';

import '../../mocks/mock_repos.dart';
import '../../mocks/mock_storage.dart';

void main() {
  test('#fromObject', () {
    final object = ReplenishmentObject(
      id: 'id',
      name: 'name',
      data: {'id': 1},
    );
    final replenishment = Replenishment.fromObject(object);
    final newObject = replenishment.toObject();

    expect(replenishment.id, equals(object.id));
    expect(replenishment.name, equals(object.name));
    expect(replenishment.data, equals(object.data));
    expect(identical(replenishment.toObject(), object), isFalse);
    expect(newObject.toMap(), equals(object.toMap()));
  });

  test('#getNumOfId', () {
    final replenishment =
        Replenishment(name: 'name', id: 'id', data: {'id': 1});

    expect(replenishment.getNumOfId('id'), equals(1));
    expect(replenishment.getNumOfId('id2'), isNull);
  });

  group('Methods With Storage', () {
    test('#remove', () async {
      LOG_LEVEL = 2;
      final replenishment = Replenishment(name: 'name', id: 'id');
      final expected = {replenishment.prefix: null};

      await replenishment.remove();

      verify(storage.set(any, argThat(equals(expected))));
      verify(replenisher.removeItem(argThat(equals('id'))));
    });

    group('#update', () {
      test('should not notify or update if not changed', () async {
        final replenishment =
            Replenishment(name: 'name', data: {'id1': 1, 'id2': 2});
        final object = ReplenishmentObject(
          name: 'name',
          data: {'id1': 1, 'id2': 2},
        );

        await replenishment.update(object);

        verifyNever(storage.set(any, any));
      });

      test('update without changing ingredient', () async {
        LOG_LEVEL = 2;
        final replenishment = Replenishment(
          name: 'name',
          data: {'id1': 1, 'id2': 2},
        );
        final object = ReplenishmentObject(
          name: 'name2',
          data: {'id1': 2, 'id2': 2, 'id3': 4},
        );

        // Action
        await replenishment.update(object);

        final prefix = replenishment.prefix;
        final expected = {
          '$prefix.name': 'name2',
          '$prefix.data.id1': 2,
          '$prefix.data.id3': 4,
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
