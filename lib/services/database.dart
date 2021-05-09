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

class SQLite {
  static final SQLite _instance = SQLite._constructor();

  static SQLite get instance => _instance;

  Database db;

  SQLite._constructor() {
    getDatabasesPath().then((databasesPath) async {
      SQLite._instance.db = await openDatabase(
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
            ['products', 'BLOB NOT NULL'],
          ];
          const orderStashColumns = <List<String>>[
            ['id', 'INTEGER PRIMARY KEY AUTOINCREMENT'],
            ['createdAt', 'INTEGER NOT NULL'],
            ['products', 'BLOB NOT NULL'],
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

  Future<int> pop(Tables table, Map<String, Object> data) {
    return db.query(TableName[table], data);
  }

  Future<int> count(Tables table) async {
    return Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${TableName[table]}'),
    );
  }
}

abstract class Snapshot {
  Map<String, dynamic> data();
}
