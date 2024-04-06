import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/services/database.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart' show databaseFactoryFfi, sqfliteFfiInit;

import '../mocks/mock_database.mocks.dart' show MockDatabaseExecutor;
import '../test_helpers/file_mocker.dart';
import 'database_test.mocks.dart';

@GenerateMocks([sqflite.Database, sqflite.Batch])
void main() {
  group('Database', () {
    group('#initialize', () {
      test('onCreate', () async {
        sqflite.databaseFactoryOrNull = databaseFactoryFfi;
        await Database.instance.initialize(
          path: sqflite.inMemoryDatabasePath,
          logWhenQuery: true,
        );

        final dbVersion = await Database.instance.db.getVersion();
        expect(dbVersion, equals(Database.latestVersion));
      });

      test('onUpgrade should not failed', () async {
        final db = await databaseFactoryFfi.openDatabase(
          sqflite.inMemoryDatabasePath,
        );
        await Database.instance.initialize(
          factory: MockDatabaseFactory(db, (path, options) async {
            expect(path, equals('databases/pos_system.sqlite'));
            await options.onUpgrade!(db, 0, options.version!);
          }),
        );
      });

      test('onUpgrade should catch the error', () async {
        Log.errorCount = 0;
        final db = await databaseFactoryFfi.openDatabase(
          sqflite.inMemoryDatabasePath,
        );

        await Database.instance.initialize(
          factory: MockDatabaseFactory(db, (path, options) async {
            // without running version 1, it will throw error
            await options.onUpgrade!(db, 3, options.version!);
          }),
        );

        expect(Log.errorCount, isNonZero);
        Log.errorCount = 0;
      });

      setUpAll(() {
        sqfliteFfiInit();
      });

      tearDownAll(() {
        Database.instance.db = MockDatabase();
      });

      tearDown(() {
        // after initialized, it can not initial again
        Database.instance = Database();
      });
    });

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

    test('#push', () async {
      final db = Database.instance.db as MockDatabase;
      when(db.insert(any, any)).thenAnswer((_) => Future.value(1));

      await Database.instance.push('table', {'a': 1});

      verify(db.insert('table', argThat(equals({'a': 1}))));
    });

    test('#query', () async {
      final db = Database.instance.db as MockDatabase;
      when(db.rawQuery(any, any)).thenAnswer((_) => Future.value([]));
      when(db.rawQuery('SELECT * FROM `table`     ')).thenAnswer((_) => Future.error('error'));

      expect(await Database.instance.query('table'), isEmpty);

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
        argThat(equals('SELECT a,b FROM `table` '
            'LEFT JOIN `guestTable`  ON `hostTable`.hostKey = `guestTable`.guestKey '
            'WHERE a = ? GROUP BY b ORDER BY a desc LIMIT 3, 5')),
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

    test('#reset', () async {
      final db = Database.instance.db as MockDatabase;
      when(db.delete(any)).thenAnswer((_) => Future.value(1));

      await Database.instance.reset('table');

      verify(db.delete('table'));

      await Database.instance.reset(null, databaseFactoryFfi.deleteDatabase);
    });

    test('#transaction', () async {
      final db = Database.instance.db as MockDatabase;
      final txn = MockDatabaseExecutor();
      when(db.transaction(any)).thenAnswer((inv) => inv.positionalArguments[0](txn));

      var fired = false;

      await Database.instance.transaction((txn) async {
        fired = true;
      });

      expect(fired, isTrue);
    });

    setUpAll(() {
      Database.instance = Database();
      Database.instance.db = MockDatabase();
      initializeFileSystem();
    });
  });
}

class MockDatabaseFactory extends sqflite.DatabaseFactory {
  final sqflite.Database db;

  final Function(String path, sqflite.OpenDatabaseOptions options) hook;

  MockDatabaseFactory(this.db, this.hook);

  @override
  Future<bool> databaseExists(String path) {
    return Future.value(false);
  }

  @override
  Future<void> deleteDatabase(String path) {
    return Future.value();
  }

  @override
  Future<String> getDatabasesPath() {
    return Future.value('databases');
  }

  @override
  Future<sqflite.Database> openDatabase(
    String path, {
    sqflite.OpenDatabaseOptions? options,
  }) async {
    await hook(path, options!);
    return db;
  }

  @override
  Future<Uint8List> readDatabaseBytes(String path) {
    return Future.value(Uint8List(0));
  }

  @override
  Future<void> setDatabasesPath(String path) {
    return Future.value();
  }

  @override
  Future<void> writeDatabaseBytes(String path, Uint8List bytes) {
    return Future.value();
  }
}
