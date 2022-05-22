import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/xfile.dart';
import 'package:possystem/services/database_migration_actions.dart';
import 'package:possystem/services/database_migrations.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

typedef DbOpener = Future<sqflite.Database> Function(
  String path, {
  int? version,
  FutureOr<void> Function(sqflite.Database)? onConfigure,
  FutureOr<void> Function(sqflite.Database, int)? onCreate,
  FutureOr<void> Function(sqflite.Database, int, int)? onUpgrade,
  FutureOr<void> Function(sqflite.Database, int, int)? onDowngrade,
  FutureOr<void> Function(sqflite.Database)? onOpen,
  bool readOnly,
  bool singleInstance,
});

class Database {
  static Database instance = Database();

  // delimiter: https://stackoverflow.com/a/29811033/12089368
  static final String delimiter = String.fromCharCode(13);

  static const latestVersion = 5;

  late sqflite.Database db;

  int _oldVersion = latestVersion;

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

  Future<void> reset(
    String? table, [
    Future<void> Function(String path) del = sqflite.deleteDatabase,
  ]) async {
    if (table == null) {
      return del(await getRootPath());
    }

    await db.delete(table);
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

    return sqflite.Sqflite.firstIntValue(result);
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

  Future<void> initialize({
    String? path,
    DbOpener opener = sqflite.openDatabase,
  }) async {
    if (_initialized) return;
    _initialized = true;

    final databasePath = path ?? await getRootPath();
    debug(databasePath, 'db.path');
    db = await opener(
      databasePath,
      version: latestVersion,
      onCreate: (db, latestVer) async {
        info(latestVer.toString(), 'database.create.$latestVer');
        for (var ver = 1; ver <= latestVer; ver++) {
          await execMigration(db, ver);
        }
      },
      onUpgrade: (db, oldVer, newVer) async {
        info(oldVer.toString(), 'database.upgrade.$newVer');
        _oldVersion = oldVer;
        for (var ver = oldVer + 1; ver <= newVer; ver++) {
          await execMigration(db, ver);
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

  Future<void> tolerateMigration({
    @visibleForTesting int newVersion = latestVersion,
    @visibleForTesting int? oldVersion,
  }) async {
    int version = (oldVersion ?? _oldVersion) + 1;
    for (; version <= newVersion; version++) {
      final action = dbMigrationActions[version];
      if (action != null) {
        info(version.toString(), 'database.migration_action');
        try {
          await action(db);
        } catch (e, stack) {
          await error(e.toString(), 'database.migration_action.error', stack);
        }
      }
    }
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

  static Future<void> execMigration(sqflite.Database db, int version) async {
    final sqlSet = dbMigrationUp[version];
    if (sqlSet == null) return;

    for (final sql in sqlSet) {
      try {
        await db.execute(sql);
      } catch (e, stack) {
        await error(e.toString(), 'database.migration.error', stack);
      }
    }
  }

  static Future<String> getRootPath() async {
    final paths = (await XFile.getRootPath()).split('/')
      ..removeLast()
      ..add('databases');
    return paths.join('/') + '/pos_system.sqlite';
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
