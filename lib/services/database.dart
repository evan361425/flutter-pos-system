import 'package:sqflite/sqflite.dart' hide Database;
import 'package:sqflite/sqflite.dart' as no_sql show Database;

enum Tables {
  search_history,
  // order
  order,
  order_stash,
}

const Map<Tables, String> TableName = {
  Tables.search_history: 'search_history',
  // order
  Tables.order: 'order',
  Tables.order_stash: 'order_stash',
};

class Database {
  static final Database _instance = Database._constructor();

  static Database get instance => _instance;

  // delimiter: https://stackoverflow.com/a/29811033/12089368
  static final String delimiter = String.fromCharCode(13);

  static String join(Iterable<String> data) {
    return data.join(delimiter) + delimiter;
  }

  no_sql.Database db;

  Database._constructor();

  Future<void> initialize() async {
    final databasePath = await getDatabasesPath() + '/pos_system.sqlite';
    db = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''CREATE TABLE `order` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  paid REAL NOT NULL,
  totalPrice REAL NOT NULL,
  totalCount INTEGER NOT NULL,
  createdAt INTEGER NOT NULL,
  usedProducts TEXT NOT NULL,
  usedIngredients TEXT NOT NULL,
  encodedProducts BLOB NOT NULL
);
''');
        await db.execute('''CREATE TABLE `order_stash` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  createdAt INTEGER NOT NULL,
  encodedProducts BLOB NOT NULL
);
''');
      },
    );
  }

  Future<int> push(Tables table, Map<String, Object> data) {
    return db.insert(TableName[table], data);
  }

  Future<int> update(
    Tables table,
    Object key,
    Map<String, Object> data, {
    keyName = 'id',
  }) {
    return db.update(
      TableName[table],
      data,
      where: '$keyName = ?',
      whereArgs: [key],
    );
  }

  Future<Map<String, Object>> getLast(
    Tables table, {
    String sortBy = 'id',
  }) async {
    try {
      final data = await db.query(
        TableName[table],
        orderBy: '$sortBy DESC',
        limit: 1,
      );
      return data.first;
    } catch (e) {
      return null;
    }
  }

  Future<void> delete(
    Tables table,
    Object id, {
    String keyName = 'id',
  }) {
    return db.delete(TableName[table], where: '$keyName = ?', whereArgs: [id]);
  }

  Future<int> count(Tables table) async {
    return Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM "${TableName[table]}"'),
    );
  }

  Future<List<Map<String, Object>>> get(
    Tables table, {
    String where,
    List<Object> whereArgs,
  }) {
    return db.query(TableName[table], where: where, whereArgs: whereArgs);
  }
}
