import 'package:path/path.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sqflite/sqflite.dart' show getDatabasesPath;

enum Stores {
  menu,
  stock,
  stock_batch,
  quantities,
}

class Storage {
  static final Storage instance = Storage._constructor();

  Database _db;

  Storage._constructor();

  Future<Database> get db async {
    if (_db == null) {
      final path = await getDatabasesPath();
      final dbPath = join(path, 'pos_system.sembast');
      _db = await databaseFactoryIo.openDatabase(dbPath);
    }

    return _db;
  }

  Future<Map<String, Object>> get(Stores storeId) async {
    final store = stringMapStoreFactory.store(storeId.toString());
    final list = await store.find(await db);
    return {for (var item in list) item.key: item.value};
  }

  /// update value
  ///
  /// ```dart
  /// // original data of object where id is some-id
  /// origin = {
  ///   'a': 'b',
  ///   'c': 'd'
  /// };
  /// data = {
  ///   'some-id': {
  ///     'a': 'e,
  ///     'f': {
  ///       'g': 'h'
  ///     }
  ///   },
  ///   'some-id.f.g': 'i,
  ///   'some-id.j': {
  ///     'k': 'l'
  ///   }
  /// }
  /// result = {
  ///   'a': 'e',
  ///   'c': 'd',
  ///   'f': {
  ///     'g': 'i'
  ///   },
  ///   'j': {
  ///     'k': 'l'
  ///   }
  /// }
  /// ```
  Future<void> set(Stores storeId, Map<String, Object> data) async {
    final refactorized = <String, Map<String, Object>>{};

    data.entries.forEach((item) {
      final index = item.key.indexOf('.');
      final id = index == -1 ? item.key : item.key.substring(0, index);
      final key = item.key.substring(index + 1);

      // make sure value be map if updating root object
      assert(
        item.value == null || index != -1 || item.value is Map,
        'when updating root object, value must be map. example: {id: mapValue}',
      );

      // if null, set to null else set to map value
      final Map<String, Object> value = item.value == null
          ? null
          : index == -1
              ? item.value
              : {key: item.value};

      if (refactorized.containsKey(id)) {
        // null will delete the record
        if (value == null) {
          refactorized[id] = null;
        } else if (refactorized[id] != null) {
          refactorized[id] = {...refactorized[id], ...value};
        }
      } else {
        refactorized[id] = value;
      }
    });

    final store = stringMapStoreFactory.store(storeId.toString());
    return (await db).transaction(
      (txn) => Future.wait([
        for (var item in refactorized.entries)
          item.value == null
              ? store.record(item.key).delete(txn)
              : store.record(item.key).update(txn, item.value)
      ]),
    );
  }

  Future<void> add(
    Stores storeId,
    String recordId,
    Map<String, Object> data,
  ) async {
    final store = stringMapStoreFactory.store(storeId.toString());
    return store.record(recordId).put(await db, data);
  }
}
