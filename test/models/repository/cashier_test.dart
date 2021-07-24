import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/objects/cashier_object.dart';
import 'package:possystem/models/repository/cashier.dart';

import '../../mocks/mocks.dart';

void main() {
  test('#setCurrent', () async {
    final cashier = Cashier();
    when(storage.set(any, any)).thenAnswer((_) => Future.value());

    // should parse success
    await cashier.setCurrent([
      <String, num>{'unit': 2, 'count': 3},
    ], []);

    expect(cashier.currentTotal, equals(6));
    verifyNever(storage.set(any, any));

    // should use currency if object is null(storage not set)
    await cashier.setCurrent(null, [1, 2, 3]);

    expect(cashier.unitLength, equals(3));
    verify(storage.set(any, any));
  });

  test('#setDefault', () async {
    final cashier = Cashier();
    when(storage.set(any, any)).thenAnswer((_) => Future.value());
    // set up current
    await cashier.setCurrent([
      <String, num>{'unit': 2, 'count': 3},
      <String, num>{'unit': 4, 'count': 5},
    ], []);

    // should true if not setup
    expect(cashier.defaultNotSet, isTrue);

    // should parse correctly
    await cashier.setDefault(record: [
      <String, num>{'unit': 1, 'count': 2},
    ]);

    expect(cashier.defaultTotal, equals(2));
    verifyNever(storage.set(any, any));

    // should use current
    await cashier.setDefault(useCurrent: true);

    expect(cashier.defaultTotal, equals(26));
    verify(storage.set(any, any));
  });

  test('#setFavorite, #deleteFavorite', () async {
    final cashier = Cashier();

    expect(cashier.favoriteIsEmpty, isTrue);

    await cashier.setFavorite([
      {
        'source': {'unit': 2, 'count': 5},
        'targets': [
          {'unit': 1, 'count': 2},
          {'unit': 4, 'count': 2},
        ],
      },
      {
        'source': {'unit': 2, 'count': 4},
        'targets': [
          {'unit': 1, 'count': 2},
          {'unit': 2, 'count': 3},
        ],
      },
    ]);

    expect(cashier.favoriteLength, equals(2));

    // delete favorite by index
    when(storage.set(any, any)).thenAnswer((_) => Future.value());
    await cashier.deleteFavorite(1);

    expect(cashier.favoriteLength, equals(1));
    verify(storage.set(any, any));

    LOG_LEVEL = 0;
    await cashier.deleteFavorite(1);
    verifyNever(storage.set(any, any));
  });

  test('#reset', () async {
    when(storage.get(any, 'some-name')).thenAnswer((_) => Future.value({
          'current': [
            {'unit': 1, 'count': 2},
            {'unit': 5, 'count': 2},
          ],
          'default': [
            {'unit': 1, 'count': 10},
            {'unit': 5, 'count': 5},
          ],
          'favorites': [
            {
              'source': {'unit': 1, 'count': 2},
              'targets': [
                {'unit': 2, 'count': 1},
              ],
            },
          ],
        }));

    final cashier = Cashier();
    await cashier.reset('some-name', []);

    expect(cashier.unitLength, equals(2));
    expect(cashier.defaultTotal, equals(35));
    expect(cashier.favoriteLength, equals(1));
  });

  group('#current', () {
    final cashier = Cashier();

    test('#add', () async {
      when(storage.set(any, any)).thenAnswer((_) => Future.value());

      await cashier.add(0, 2);

      expect(cashier.at(0).count, equals(6));
      verify(storage.set(any, any));
    });

    test('#minus', () async {
      when(storage.set(any, any)).thenAnswer((_) => Future.value());

      await cashier.minus(0, 6);

      expect(cashier.at(0).count, equals(0));
      verify(storage.set(any, any));
    });

    test('#update', () async {
      when(storage.set(any, any)).thenAnswer((_) => Future.value());

      await cashier.update({0: 2, 1: -3});

      expect(cashier.at(0).count, equals(6));
      expect(cashier.at(1).count, equals(2));
      verify(storage.set(any, any));
    });

    test('#update but not update to storage', () async {
      await cashier.update({0: 0, 1: 0});

      verifyNever(storage.set(any, any));
    });

    setUp(() async {
      await cashier.setCurrent([
        <String, num>{'unit': 2, 'count': 4},
        <String, num>{'unit': 3, 'count': 5},
      ], []);
    });
  });

  test('#applyFavorite', () async {
    final cashier = Cashier();
    when(storage.set(any, any)).thenAnswer((_) => Future.value());
    await cashier.setCurrent([
      <String, num>{'unit': 1, 'count': 0},
      <String, num>{'unit': 2, 'count': 3},
    ], []);
    await cashier.setFavorite([
      {
        'source': {'unit': 2, 'count': 1},
        'targets': [
          {'unit': 1, 'count': 2},
        ],
      },
    ]);

    final item = cashier.favoriteAt(0);
    final shouldValid = await cashier.applyFavorite(item);

    expect(shouldValid, isTrue);
    expect(cashier.at(0).count, equals(2));
    expect(cashier.at(1).count, equals(2));
    verify(storage.set(any, any));

    final shouldInvalid = await cashier.applyFavorite(CashierChangeBatchObject(
      source: CashierChangeEntryObject(count: 10, unit: 2),
      targets: [CashierChangeEntryObject(count: 20, unit: 1)],
    ));

    expect(shouldInvalid, isFalse);
    verifyNever(storage.set(any, any));
  });

  group('#paid', () {
    test('should update current money correctly', () {
      final cashier = Cashier();
      when(storage.set(any, any)).thenAnswer((_) => Future.value());
      cashier.setCurrent([
        <String, num>{'unit': 10, 'count': 3},
        <String, num>{'unit': 50, 'count': 3},
        <String, num>{'unit': 100, 'count': 1},
        <String, num>{'unit': 500, 'count': 3},
      ], []);

      cashier.paid(1000, 240); // should change 760

      // although 100 is not enough, it should work correcty
      expect(cashier.at(0).count, equals(2));
      expect(cashier.at(1).count, equals(2));
      expect(cashier.at(2).count, equals(0));
      expect(cashier.at(3).count, equals(4));
    });

    test('should feedback old price', () {
      final cashier = Cashier();
      when(storage.set(any, any)).thenAnswer((_) => Future.value());
      cashier.setCurrent([
        <String, num>{'unit': 50, 'count': 5},
        <String, num>{'unit': 100, 'count': 10},
        <String, num>{'unit': 1000, 'count': 0},
      ], []);

      cashier.paid(1000, 250, 300); // should change 50

      // although 100 is not enough, it should work correcty
      expect(cashier.at(0).count, equals(4));
      expect(cashier.at(1).count, equals(10));
      expect(cashier.at(2).count, equals(0));
    });
  });

  group('#findPossibleChange', () {
    final cashier = Cashier();

    test('change(1, 100)', () {
      final result = cashier.findPossibleChange(1, 100);
      expect(result!.count, equals(10));
      expect(result.unit, equals(10));
    });
    test('change(1, 10)', () {
      final result = cashier.findPossibleChange(1, 10);
      expect(result, isNull);
    });
    test('change(6, 100)', () {
      final result = cashier.findPossibleChange(6, 100);
      expect(result!.count, equals(1));
      expect(result.unit, equals(500));
    });
    test('change(4, 100)', () {
      final result = cashier.findPossibleChange(4, 100);
      expect(result!.count, equals(40));
      expect(result.unit, equals(10));
    });
    test('change(9, 10)', () {
      final result = cashier.findPossibleChange(9, 10);
      expect(result, isNull);
    });
    test('guard some impossible things', () {
      expect(cashier.findPossibleChange(0, 10), isNull);
      expect(cashier.findPossibleChange(1, 1), isNull);
    });

    setUpAll(() => cashier.setCurrent(null, [10, 100, 500]));
  });

  test('#getDifference', () async {
    final cashier = Cashier();
    when(storage.get(any, any)).thenAnswer((_) => Future.value({
          'current': [
            {'unit': 1, 'count': 2},
            {'unit': 5, 'count': 2},
          ],
          'default': [
            {'unit': 1, 'count': 10},
          ],
        }));

    await cashier.reset('', []);

    final result = cashier.getDifference().toList();

    expect(result.length, equals(1));
    expect(result[0].fold<num>(0, (v, e) => v + e.total), equals(12));
  });

  test('#surplus', () async {
    final cashier = Cashier();
    when(storage.get(any, any)).thenAnswer((_) => Future.value({
          'current': [
            {'unit': 1, 'count': 2},
            {'unit': 5, 'count': 2},
          ],
          'default': [
            {'unit': 1, 'count': 10},
            {'unit': 5, 'count': 5},
          ],
        }));
    when(storage.set(any, any)).thenAnswer((_) => Future.value());

    await cashier.reset('', []);
    expect(cashier.currentTotal, equals(12));
    expect(cashier.defaultTotal, equals(35));

    await cashier.surplus();
    expect(cashier.currentTotal, equals(35));
  });

  setUpAll(() {
    initialize();
  });
}
