import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/repository/seller.dart';

import '../../mocks/mock_database.dart';
import '../../mocks/mock_models.mocks.dart';

void main() {
  final seller = Seller();
  group('getter', () {
    test('#getCountBetween', () async {
      final nowUTC =
          DateTime(2021, 10, 10, 1, 1, 1).millisecondsSinceEpoch ~/ 1000;
      final nextUTC = nowUTC + 100;
      when(database.rawQuery(
        any,
        columns: anyNamed('columns'),
        where: anyNamed('where'),
        groupBy: anyNamed('groupBy'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) => Future.value(
            [
              {'createdAt': nowUTC, 'count': 1},
              {'createdAt': nextUTC, 'count': 2},
            ],
          ));

      final result =
          await seller.getCountBetween(DateTime.now(), DateTime.now());

      expect(
          result,
          equals({
            DateTime.fromMillisecondsSinceEpoch(nowUTC * 1000): 1,
            DateTime.fromMillisecondsSinceEpoch(nextUTC * 1000): 2
          }));
    });

    test('#getMetricBetween in empty result', () async {
      when(database.query(
        any,
        columns: anyNamed('columns'),
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) => Future.value([]));

      final result = await seller.getMetricBetween();

      expect(result, equals({'totalPrice': 0, 'count': 0}));
    });

    test('#getMetricBetween', () async {
      when(database.query(
        any,
        columns: anyNamed('columns'),
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) => Future.value([
            {'totalPrice': 1, 'count': 2},
          ]));

      final result =
          await seller.getMetricBetween(DateTime.now(), DateTime.now());

      expect(result, equals({'totalPrice': 1, 'count': 2}));
    });

    test('#getOrderBetween', () async {
      when(database.query(
        any,
        orderBy: anyNamed('orderBy'),
        // limit for latency
        limit: 10,
        offset: 0,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) => Future.value([]));

      final result =
          await seller.getOrderBetween(DateTime.now(), DateTime.now());

      expect(result, isEmpty);
    });

    test('#getStashCount in null', () async {
      when(database.count(any)).thenAnswer((_) => Future.value(null));

      final result = await seller.getStashCount();

      expect(result, equals(0));
    });

    test('#getStashCount', () async {
      when(database.count(any)).thenAnswer((_) => Future.value(3));

      final result = await seller.getStashCount();

      expect(result, equals(3));
    });
  });

  group('#drop', () {
    test('null result', () async {
      when(database.getLast(any, columns: anyNamed('columns')))
          .thenAnswer((_) => Future.value(null));

      final result = await seller.drop();

      expect(result, equals(null));
      verifyNever(database.delete(any, any));
    });

    test('positive result', () async {
      when(database.getLast(any, columns: anyNamed('columns')))
          .thenAnswer((_) => Future.value({'id': 1}));

      final result = await seller.drop();

      expect(result?.id, equals(1));
      verify(database.delete(any, argThat(equals(1))));
    });
  });

  group('#pop', () {
    test('null result', () async {
      when(database.getLast(any,
              columns: anyNamed('columns'),
              where: anyNamed('where'),
              whereArgs: anyNamed('whereArgs')))
          .thenAnswer((_) => Future.value(null));

      final result = await seller.pop();

      expect(result, equals(null));
    });

    test('positive result', () async {
      when(database.getLast(any,
              columns: anyNamed('columns'),
              where: anyNamed('where'),
              whereArgs: anyNamed('whereArgs')))
          .thenAnswer((_) => Future.value({'id': 1}));

      final result = await seller.pop();

      expect(result?.id, equals(1));
    });
  });

  test('#push', () async {
    final object = MockOrderObject();

    when(object.toMap()).thenReturn({'a': 'b'});
    when(database.push(any, argThat(equals({'a': 'b'}))))
        .thenAnswer((_) => Future.value(1));

    await seller.push(object);
  });

  test('#stash', () async {
    final object = MockOrderObject();
    final map = {'createdAt': 'a', 'encodedProducts': 'b'};

    when(object.toMap()).thenReturn(map);
    when(database.push(any, argThat(equals(map))))
        .thenAnswer((_) => Future.value(1));

    await seller.stash(object);
  });

  test('#update', () async {
    final object = MockOrderObject();
    final map = {'a': 'b'};

    when(object.toMap()).thenReturn(map);
    when(object.id).thenReturn(2);
    when(database.update(any, argThat(equals(2)), argThat(equals(map))))
        .thenAnswer((_) => Future.value(1));

    await seller.update(object);
  });

  setUpAll(() {
    initializeDatabase();
  });
}
