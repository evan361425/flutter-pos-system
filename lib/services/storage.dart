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

  Future<void> set(Stores storeId, Map<String, Object> data) async {
    final store = stringMapStoreFactory.store(storeId.toString());

    return (await db).transaction((txn) {
      final futures = <Future<Object>>[];

      data.entries.forEach((item) {
        final index = item.key.indexOf('.');
        // update object directly
        if (index == -1) {
          futures.add(
            item.value == null
                ? store.record(item.key).delete(txn)
                : store.record(item.key).update(txn, {item.key: item.value}),
          );
        } else {
          // using root id
          final ref = store.record(item.key.substring(0, index));
          // using object key
          futures.add(
            ref.update(txn, {item.key.substring(index + 1): item.value}),
          );
        }
      });

      return Future.wait(futures);
    });
  }

  Future<void> add(
    Stores storeId,
    String recordId,
    Map<String, Object> data,
  ) async {
    final store = stringMapStoreFactory.store(storeId.toString());
    return store.record(recordId).add(await db, data);
  }
}
