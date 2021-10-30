import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/services/database.dart';
import 'package:sqflite/sqflite.dart' as sqflite show Database, Batch;

import 'database_test.mocks.dart';

@GenerateMocks([sqflite.Database, sqflite.Batch])
void main() {
  group('Database', () {
    test('#batchUpdate', () async {
      final batch = MockBatch();
      when(Database.instance.db.batch()).thenReturn(batch);
      when(batch.update(
        any,
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenReturn(null);
      when(batch.commit()).thenAnswer((realInvocation) => Future.value([]));

      await Database.instance.batchUpdate(
        'table',
        [
          {'1': 1},
          {'2': 2},
        ],
        where: 'where',
        whereArgs: [
          [1],
          [2],
        ],
      );

      verify(batch.update(
        'table',
        argThat(equals({'1': 1})),
        where: argThat(equals('where'), named: 'where'),
        whereArgs: argThat(equals([1]), named: 'whereArgs'),
      ));
      verify(batch.update(
        'table',
        argThat(equals({'2': 2})),
        where: argThat(equals('where'), named: 'where'),
        whereArgs: argThat(equals([2]), named: 'whereArgs'),
      ));
      verify(batch.commit());
    });

    test('#count', () async {
      when(Database.instance.db.query(
        'table',
        columns: anyNamed('columns'),
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) => Future.value([
            {'count': 1}
          ]));

      final result = await Database.instance.count(
        'table',
        where: 'a',
        whereArgs: ['b'],
      );

      expect(result, equals(1));

      verify(Database.instance.db.query(
        'table',
        columns: argThat(equals(['COUNT(*)']), named: 'columns'),
        where: argThat(equals('a'), named: 'where'),
        whereArgs: argThat(equals(['b']), named: 'whereArgs'),
      ));
    });

    test('#delete', () async {
      when(Database.instance.db.delete(
        'table',
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) => Future.value(1));

      await Database.instance.delete('table', '1', keyName: 'a');

      verify(Database.instance.db.delete(
        'table',
        where: argThat(equals('a = ?'), named: 'where'),
        whereArgs: argThat(equals(['1']), named: 'whereArgs'),
      ));
    });

    test('#getLast', () async {
      final db = Database.instance.db as MockDatabase;

      // get last 3
      when(db.rawQuery(any, any)).thenAnswer((_) => Future.value([
            {},
            {},
            {'a': 'b'}
          ]));

      var result = await Database.instance.getLast(
        'table',
        orderByKey: 'a',
        columns: ['a'],
        where: 'a = b',
        whereArgs: [1],
        count: 3,
      );

      expect(result, equals({'a': 'b'}));
      verify(db.rawQuery(
        'SELECT a FROM `table`  WHERE a = b  ORDER BY a DESC LIMIT 0, 3',
        argThat(equals([1])),
      ));

      // get last
      when(db.rawQuery(any, any)).thenAnswer((_) => Future.value([
            {'a': 'b'}
          ]));

      result = await Database.instance.getLast('table');

      expect(result, equals({'a': 'b'}));
      verify(db.rawQuery(
          'SELECT * FROM `table`    ORDER BY id DESC LIMIT 0, 1', any));

      // get empty
      when(db.rawQuery(any, any)).thenAnswer((_) => Future.value([]));

      result = await Database.instance.getLast('table', where: 'a = b');

      expect(result, isNull);
      verify(db.rawQuery(
          'SELECT * FROM `table`  WHERE a = b  ORDER BY id DESC LIMIT 0, 1',
          any));
    });

    test('#push', () async {
      final db = Database.instance.db as MockDatabase;
      when(db.insert(any, any)).thenAnswer((_) => Future.value(1));

      await Database.instance.push('table', {'a': 1});

      verify(db.insert('table', argThat(equals({'a': 1}))));
    });

    test('#query', () async {
      final db = Database.instance.db as MockDatabase;
      when(db.rawQuery(any, any)).thenAnswer((_) => Future.value([]));

      await Database.instance.query('table');

      verify(db.rawQuery('SELECT * FROM `table`     '));

      await Database.instance.query(
        'table',
        where: 'a = ?',
        whereArgs: [1],
        columns: ['a', 'b'],
        groupBy: 'b',
        orderBy: 'a desc',
        join: const JoinQuery(
            hostTable: 'hostTable',
            guestTable: 'guestTable',
            hostKey: 'hostKey',
            guestKey: 'guestKey',
            joinType: 'LEFT'),
        limit: 5,
        offset: 3,
      );

      verify(db.rawQuery(
        argThat(equals(
            'SELECT a,b FROM `table` LEFT JOIN `guestTable` ON `hostTable`.hostKey = `guestTable`.guestKey WHERE a = ? GROUP BY b ORDER BY a desc LIMIT 3, 5')),
        argThat(equals([1])),
      ));
    });

    test('#update', () async {
      final db = Database.instance.db as MockDatabase;
      when(db.update(
        any,
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) => Future.value(1));

      await Database.instance.update('table', 1, {'a': 'b'}, keyName: 'c');

      verify(db.update(
        'table',
        argThat(equals({'a': 'b'})),
        where: argThat(equals('c = ?'), named: 'where'),
        whereArgs: argThat(equals([1]), named: 'whereArgs'),
      ));
    });

    setUpAll(() {
      Database.instance = Database();
      Database.instance.db = MockDatabase();
    });
  });
}
