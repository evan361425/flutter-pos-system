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

  no_sql.Database db;

  Database._constructor() {
    getDatabasesPath().then((databasesPath) async {
      db = await openDatabase(
        databasesPath + '/pos_system.sqlite',
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''CREATE TABLE `search_history` (
  type TEXT NOT NULL,
  value TEXT NOT NULL
);
''');
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
    });
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
