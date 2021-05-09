import 'package:sqflite/sqflite.dart';

enum Collections {
  menu,
  quantities,
  search_history,
  stock_batch,
  stock,
}

enum Tables {
  order,
  order_stash,
}

const Map<Collections, String> CollectionName = {
  Collections.menu: 'menu',
  Collections.quantities: 'quantities',
  Collections.search_history: 'search_history',
  Collections.stock_batch: 'stock_batch',
  Collections.stock: 'stock',
};

const Map<Tables, String> TableName = {
  Tables.order: 't_order',
  Tables.order_stash: 't_order_stash',
};

abstract class Document<T extends Snapshot> {
  static Document instance;

  Future<T> get(Collections collection);
  Future<void> set(Collections collection, Map<String, dynamic> data);
  Future<void> update(Collections collection, Map<String, dynamic> data);
}

class Storage {
  static final Storage _instance = Storage._constructor();

  static Storage get instance => _instance;

  Database db;

  Storage._constructor() {
    getDatabasesPath().then((databasesPath) async {
      Storage._instance.db = await openDatabase(
        databasesPath + '/pos_system.db',
        version: 1,
        onCreate: (db, version) async {
          const orderColumns = <List<String>>[
            ['id', 'INTEGER PRIMARY KEY AUTOINCREMENT'],
            ['paid', 'REAL NOT NULL'],
            ['totalPrice', 'REAL NOT NULL'],
            ['totalCount', 'INTEGER NOT NULL'],
            ['createdAt', 'INTEGER NOT NULL'],
            ['usedProducts', 'TEXT NOT NULL'],
            ['usedIngredients', 'TEXT NOT NULL'],
            ['encodedProducts', 'BLOB NOT NULL'],
          ];
          const orderStashColumns = <List<String>>[
            ['id', 'INTEGER PRIMARY KEY AUTOINCREMENT'],
            ['createdAt', 'INTEGER NOT NULL'],
            ['encodedProducts', 'BLOB NOT NULL'],
          ];
          await db.execute(
            'CREATE TABLE ${TableName[Tables.order]} (${orderColumns.map((column) => column.join(' ')).join(',')})',
          );
          await db.execute(
            'CREATE TABLE ${TableName[Tables.order_stash]} (${orderStashColumns.map((column) => column.join(' ')).join(',')})',
          );
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
    column = 'id',
  }) {
    return db.update(
      TableName[table],
      data,
      where: '$column = ?',
      whereArgs: [key],
    );
  }

  Future<Map<String, Object>> getLast(
    Tables table, {
    String column = 'id',
  }) async {
    try {
      final data = await db.query(
        TableName[table],
        orderBy: '$column DESC',
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
}

abstract class Snapshot {
  Map<String, dynamic> data();
}
