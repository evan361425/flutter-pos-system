import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/xfile.dart';
import 'package:sembast/sembast_io.dart';

class Storage {
  static Storage instance = Storage();

  late Database db;

  bool _initialized = false;

  /// add data into record, overwrite and create if needed
  Future<void> add(
    Stores storeId,
    String recordId,
    Map<String, Object?> data,
  ) {
    return getStore(storeId).record(recordId).put(db, data);
  }

  Future<Map<String, Object?>> get(Stores storeId, [String? record]) async {
    if (record != null) {
      final data = await getStore(storeId).record(record).get(db);
      if (data == null) return {};

      return data as Map<String, Object?>;
    }

    final list = await getStore(storeId).find(db);

    return {for (var item in list) item.key as String: item.value};
  }

  Future<void> initialize({StorageOpener? opener}) async {
    if (_initialized) return;
    _initialized = true;

    final path = await getRootPath();
    Log.out('start', 'storage_initialize');
    db = await (opener ?? databaseFactoryIo.openDatabase)(path);
  }

  Future<void> reset(
    Stores? storeId, [
    Future<void> Function(String path)? del,
  ]) async {
    if (storeId == null) {
      return (del ?? databaseFactoryIo.deleteDatabase)(await getRootPath());
    }

    final store = getStore(storeId);
    await store.drop(db);
  }

  StorageSanitizedData sanitize(Map<String, Object?> data) {
    final sanitizedData = StorageSanitizedData();
    data.forEach((key, value) => sanitizedData.add(StorageSanitizedValue(key, value)));
    return sanitizedData;
  }

  /// update value
  Future<void> set(Stores storeId, Map<String, Object?> data) {
    final sanitizedData = sanitize(data);
    final store = getStore(storeId);

    return db.transaction((txn) => Future.wait(sanitizedData.data.entries.map((entry) {
          return entry.value == null
              ? store.record(entry.key).delete(txn)
              : store.record(entry.key).update(txn, entry.value);
        })));
  }

  Future<void> setAll(Stores storeId, Map<String, Object?> data) {
    final store = getStore(storeId);

    return db.transaction((txn) => Future.wait(data.entries.map(
          (e) => store.record(e.key).put(txn, e.value, merge: true),
        )));
  }

  static Future<String> getRootPath() async {
    final paths = (await XFile.getRootPath()).split('/')
      ..removeLast()
      ..add('databases');
    return '${paths.join('/')}/pos_system.sembast';
  }

  /// Get string map Store
  ///
  /// variable to make it easy to test
  static StoreRef getStore(Stores storeId) => stringMapStoreFactory.store(storeId.toString());
}

class StorageSanitizedData {
  final data = <String, Object?>{};

  void add(StorageSanitizedValue value) {
    // null will delete the record
    if (value.data == null) {
      data[value.id] = null;
      return;
    }

    // if already set to null, ignore all operation
    if (data.containsKey(value.id) && data[value.id] == null) {
      return;
    }

    // initialize
    if (data[value.id] == null) {
      if (value.data is Map) {
        data[value.id] = value.data;
      }
      return;
    }

    // only use first setting value
    if (data[value.id] is! Map || value.data is! Map) {
      return;
    }

    // check overlap
    data[value.id] = {...data[value.id] as Map, ...value.data as Map};
  }

  /// Update [origin] value from [source]
  ///
  /// if origin value is [FieldValue.delete] it will ignoring any action
  void updateOverlap(Map origin, Map source) {
    source.forEach((key, value) {
      if (origin.containsKey(key)) {
        final originValue = origin[key];

        if (value is Map && originValue is Map) {
          updateOverlap(originValue, value);
        } else if (value != originValue) {
          // update to new value only if origin is not trying to delete it
          if (originValue != FieldValue.delete) {
            origin[key] = value;
          }
        }
      } else {
        // insert new value
        origin[key] = value;
      }
    });
  }
}

enum Stores {
  menu,
  stock,
  replenisher,
  quantities,
  cashier,
  orderAttributes,
  analysis,
  printers,
}

class StorageSanitizedValue {
  late final String id;
  late final Object? data;

  StorageSanitizedValue(String key, Object? value) {
    final index = key.indexOf('.');

    // key without "." or postfix "."
    if (index == -1 || key.length == index + 1) {
      id = key.substring(0, index == -1 ? null : index);
      data = value;
    } else {
      id = key.substring(0, index);
      data = {key.substring(index + 1): value ?? FieldValue.delete};
    }
  }
}

typedef StorageOpener = Future<Database> Function(
  String path, {
  int? version,
  Future<dynamic> Function(Database, int, int)? onVersionChanged,
  DatabaseMode? mode,
  SembastCodec? codec,
});
