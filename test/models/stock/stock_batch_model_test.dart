import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/stock/stock_batch_model.dart';

import '../../mocks/mocks.dart';

void main() {
  test('#fromObject', () {
    final object = StockBatchObject(
      id: 'id',
      name: 'name',
      data: {'id': 1},
    );
    final batch = StockBatchModel.fromObject(object);
    final newObject = batch.toObject();

    expect(batch.id, equals(object.id));
    expect(batch.name, equals(object.name));
    expect(batch.data, equals(object.data));
    expect(identical(batch.toObject(), object), isFalse);
    expect(newObject.toMap(), equals(object.toMap()));
  });

  test('#getNumOfId', () {
    final batch = StockBatchModel(name: 'name', id: 'id', data: {'id': 1});

    expect(batch.getNumOfId('id'), equals(1));
    expect(batch.getNumOfId('id2'), isNull);
  });

  group('Methods With Storage', () {
    test('#remove', () async {
      LOG_LEVEL = 2;
      final batch = StockBatchModel(name: 'name', id: 'id');
      final expected = {batch.prefix: null};

      await batch.remove();

      verify(storage.set(any, argThat(equals(expected))));
      verify(batches.removeItem(argThat(equals('id'))));
    });

    group('#update', () {
      test('should not notify or update if not changed', () async {
        final batch = StockBatchModel(name: 'name', data: {'id1': 1, 'id2': 2});
        final object = StockBatchObject(
          name: 'name',
          data: {'id1': 1, 'id2': 2},
        );

        await batch.update(object);

        verifyNever(storage.set(any, any));
      });

      test('update without changing ingredient', () async {
        LOG_LEVEL = 2;
        final batch = StockBatchModel(name: 'name', data: {'id1': 1, 'id2': 2});
        final object = StockBatchObject(
          name: 'name2',
          data: {'id1': 2, 'id2': 2, 'id3': 4},
        );

        // Action
        await batch.update(object);

        final prefix = batch.prefix;
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
    initialize();
  });
}
