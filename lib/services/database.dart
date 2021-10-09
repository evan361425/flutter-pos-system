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
    String orderByKey = 'id',
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    JoinQuery? join,
  }) async {
    try {
      final data = await rawQuery(
        table,
        columns: columns,
        orderBy: '$orderByKey DESC',
        limit: 1,
        where: where,
        whereArgs: whereArgs,
        join: join,
      );
      return data.first;
    } catch (e) {
      return null;
    }
  }

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    final databasePath = await getDatabasesPath() + '/pos_system.sqlite';
    db = await openDatabase(
      databasePath,
      version: 2,
      onCreate: (db, version) async {
        info(version.toString(), 'database.create.$version');
        for (var exeVersion = 1; exeVersion <= version; exeVersion++) {
          await _execMigration(exeVersion);
        }
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        info(oldVersion.toString(), 'database.upgrade.$newVersion');
        await _execMigration(newVersion);
      },
    );
  }

  Future<void> _execMigration(int version) async {
    for (final sql in DB_MIG_UP[version]!) {
      try {
        await db.execute(sql);
      } catch (e, stack) {
        await error(e.toString(), 'database.migration.error', stack);
      }
    }
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
    List<Object?>? whereArgs,
    List<String>? columns,
    JoinQuery? join,
    String? groupBy,
    String? orderBy,
    int? limit,
    int offset = 0,
  }) {
    final selectQuery = columns?.join(',') ?? '*';
    final groupByQuery = groupBy == null ? '' : 'GROUP BY $groupBy';
    final orderByQuery = orderBy == null ? '' : 'ORDER BY $orderBy';
    final limitQuery = limit == null ? '' : 'LIMIT $offset, $limit';
    final joinQuery = join == null ? '' : join.toString();

    return instance.db.rawQuery('''
    SELECT $selectQuery FROM `$table`
    WHERE $where
    $joinQuery
    $groupByQuery
    $orderByQuery
    $limitQuery''', whereArgs);
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
    return '$joinType JOIN $guestTable ON $hostTable.$hostKey = $guestTable.$guestKey';
  }
}
