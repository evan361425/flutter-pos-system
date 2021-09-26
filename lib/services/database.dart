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

  Future<int?> count(
    String table, {
    String? where,
    List<Object>? whereArgs,
  }) async {
    final result = await db.query(table, columns: ['COUNT(*)']);

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
    String sortBy = 'id',
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
  }) async {
    try {
      final data = await db.query(
        table,
        columns: columns,
        orderBy: '$sortBy DESC',
        limit: 1,
        where: where,
        whereArgs: whereArgs,
      );
      return data.first;
    } catch (e) {
      return null;
    }
  }

  Future<void> initialize() async {
    if (_initialized) return;

    final databasePath = await getDatabasesPath() + '/pos_system.sqlite';
    db = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) {
        info(version.toString(), 'database.create');
        return Future.wait(DB_MIG_UP[1]!.map((sql) => db.execute(sql)));
      },
    );
    _initialized = true;
  }

  Future<int> push(String table, Map<String, Object?> data) {
    return db.insert(table, data);
  }

  Future<List<Map<String, Object?>>> query(
    String table, {
    String? where,
    List<Object>? whereArgs,
    bool? distinct,
    List<String>? columns,
    String? groupBy,
    String? orderBy,
    String? having,
    int? limit,
    int? offset,
  }) {
    return instance.db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      distinct: distinct,
      columns: columns,
      groupBy: groupBy,
      orderBy: orderBy,
      having: having,
      limit: limit,
      offset: offset,
    );
  }

  Future<List<Map<String, Object?>>> rawQuery(
    String table, {
    String? where,
    List<Object>? whereArgs,
    List<String> columns = const ['*'],
    String? join,
    String? groupBy,
  }) {
    final select = columns.join(',');
    final groupByQuery = groupBy == null ? '' : 'GROUP BY $groupBy';

    return instance.db.rawQuery('''
    SELECT $select FROM $table
    WHERE $where
    $join
    $groupByQuery''', whereArgs);
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

  static String join(Iterable<String>? data) =>
      (data?.join(delimiter) ?? '') + delimiter;

  static List<String> split(String? value) =>
      value?.trim().split(delimiter) ?? [];
}
