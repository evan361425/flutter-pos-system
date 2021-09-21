import 'package:possystem/helpers/logger.dart';
import 'package:possystem/services/database_migrations.dart';
import 'package:sqflite/sqflite.dart' hide Database;
import 'package:sqflite/sqflite.dart' as no_sql show Database;

const Map<Tables, String> TableName = {
  Tables.search_history: 'search_history',
  // order
  Tables.order: 'order',
  Tables.order_stash: 'order_stash',
};

class Database {
  static Database instance = Database();

  // delimiter: https://stackoverflow.com/a/29811033/12089368
  static final String delimiter = String.fromCharCode(13);

  late no_sql.Database db;

  bool _initialized = false;

  Future<int?> count(
    Tables table, {
    String? where,
    List<Object>? whereArgs,
  }) async {
    final result = await db.query(TableName[table]!, columns: ['COUNT(*)']);

    return Sqflite.firstIntValue(result);
  }

  Future<void> delete(
    Tables table,
    Object? id, {
    String keyName = 'id',
  }) {
    return db.delete(TableName[table]!, where: '$keyName = ?', whereArgs: [id]);
  }

  Future<Map<String, Object?>?> getLast(
    Tables table, {
    String sortBy = 'id',
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
  }) async {
    try {
      final data = await db.query(
        TableName[table]!,
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

  Future<int> push(Tables table, Map<String, Object?> data) {
    return db.insert(TableName[table]!, data);
  }

  Future<List<Map<String, Object?>>> query(
    Tables table, {
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
      TableName[table]!,
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
    Tables table, {
    String? where,
    List<Object>? whereArgs,
    required List<String> columns,
    String? groupBy,
  }) {
    final select = columns.join(',');
    return instance.db.rawQuery('''
    SELECT $select FROM "${TableName[table]}"
    WHERE $where
    GROUP BY $groupBy''', whereArgs);
  }

  Future<int> update(
    Tables table,
    Object? key,
    Map<String, Object?> data, {
    keyName = 'id',
  }) {
    return db.update(
      TableName[table]!,
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

enum Tables {
  search_history,
  // order
  order,
  order_stash,
}
