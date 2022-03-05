import 'dart:math';

import 'package:possystem/helpers/logger.dart';
import 'package:possystem/services/database_migrations.dart';
import 'package:sqflite/sqflite.dart' hide Database;
import 'package:sqflite/sqflite.dart' as no_sql show Database;

class Database {
  static Database instance = Database();

  // delimiter: https://stackoverflow.com/a/29811033/12089368
  static final String delimiter = String.fromCharCode(13);

  late no_sql.Database db;

  bool _initialized = false;

  Future<List<Object?>> batchUpdate(
    String table,
    List<Map<String, Object?>> data, {
    required String where,
    required List<List<Object>> whereArgs,
  }) {
    final batch = db.batch();
    final maxLength = min(data.length, whereArgs.length);

    for (var i = 0; i < maxLength; i++) {
      batch.update(table, data[i], where: where, whereArgs: whereArgs[i]);
    }

    return batch.commit();
  }

  Future<int?> count(
    String table, {
    String? where,
    List<Object>? whereArgs,
  }) async {
    final result = await db.query(
      table,
      columns: ['COUNT(*)'],
      where: where,
      whereArgs: whereArgs,
    );

    return Sqflite.firstIntValue(result);
  }

  Future<void> delete(
    String table,
    Object? id, {
    String keyName = 'id',
  }) {
    return db.delete(table, where: '$keyName = ?', whereArgs: [id]);
  }

  Future<Map<String, Object?>?> getLast(
    String table, {
    String orderByKey = 'id',
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    JoinQuery? join,
    int count = 1,
  }) async {
    final data = await query(
      table,
      columns: columns,
      orderBy: '$orderByKey DESC',
      limit: count,
      where: where,
      whereArgs: whereArgs,
      join: join,
    );
    return data.isEmpty ? null : data[count - 1];
  }

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    final databasePath = await getDatabasesPath() + '/pos_system.sqlite';
    db = await openDatabase(
      databasePath,
      version: 4,
      onCreate: (db, version) async {
        info(version.toString(), 'database.create.$version');
        for (var exeVersion = 1; exeVersion <= version; exeVersion++) {
          await _execMigration(db, exeVersion);
        }
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        info(oldVersion.toString(), 'database.upgrade.$newVersion');
        for (var i = oldVersion + 1; i <= newVersion; i++) {
          await _execMigration(db, i);
        }
      },
    );
  }

  Future<int> push(String table, Map<String, Object?> data) {
    return db.insert(table, data);
  }

  Future<List<Map<String, Object?>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    List<String>? columns,
    JoinQuery? join,
    String? groupBy,
    String? orderBy,
    int? limit,
    int offset = 0,
  }) async {
    final selectQuery = columns?.join(',') ?? '*';
    final whereQuery = where == null ? '' : 'WHERE $where';
    final groupByQuery = groupBy == null ? '' : 'GROUP BY $groupBy';
    final orderByQuery = orderBy == null ? '' : 'ORDER BY $orderBy';
    final limitQuery = limit == null ? '' : 'LIMIT $offset, $limit';
    final joinQuery = join == null ? '' : join.toString();

    try {
      return await db.rawQuery(
        'SELECT $selectQuery FROM `$table` $joinQuery $whereQuery $groupByQuery $orderByQuery $limitQuery',
        whereArgs,
      );
    } catch (e, stack) {
      error(e.toString(), 'db.query.error', stack);
      return [];
    }
  }

  Future<void> reset() async {
    final path = await getDatabasesPath() + '/pos_system.sqlite';
    return deleteDatabase(path);
  }

  Future<int> update(
    String table,
    Object? key,
    Map<String, Object?> data, {
    keyName = 'id',
  }) {
    return db.update(
      table,
      data,
      where: '$keyName = ?',
      whereArgs: [key],
    );
  }

  Future<void> _execMigration(no_sql.Database db, int version) async {
    final sqls = dbMigrationUp[version];
    if (sqls == null) return;

    for (final sql in sqls) {
      try {
        await db.execute(sql);
      } catch (e, stack) {
        await error(e.toString(), 'database.migration.error', stack);
      }
    }
  }

  static String join(Iterable<String>? data) =>
      (data?.join(delimiter) ?? '') + delimiter;

  static List<String> split(String? value) =>
      value?.trim().split(delimiter) ?? [];
}

class JoinQuery {
  final String hostTable;
  final String guestTable;
  final String hostKey;
  final String guestKey;
  final String joinType;

  const JoinQuery({
    required this.hostTable,
    required this.guestTable,
    required this.hostKey,
    required this.guestKey,
    this.joinType = 'INNER',
  });

  @override
  String toString() {
    return '$joinType JOIN `$guestTable` ON `$hostTable`.$hostKey = `$guestTable`.$guestKey';
  }
}
