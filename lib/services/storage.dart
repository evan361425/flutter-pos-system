import 'package:possystem/helpers/logger.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sqflite/sqflite.dart' show getDatabasesPath;

enum Stores {
  menu,
  stock,
  replenisher,
  quantities,
  cashier,
  customers,
}

class Storage {
  static Storage instance = Storage();

  late Database db;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    final databasePath = await getDatabasesPath() + '/pos_system.sembast';

    db = await databaseFactoryIo.openDatabase(databasePath);
  }

  Future<void> deleteAll() async {
    final databasePath = await getDatabasesPath() + '/pos_system.sembast';

    await databaseFactoryIo.deleteDatabase(databasePath);
  }

  /// Get string map Store
  ///
  /// variable to make it easy to test
  static StoreRef getStore(Stores storeId) =>
      stringMapStoreFactory.store(storeId.toString());

  Future<Map<String, Object?>> get(Stores storeId, [String? record]) async {
    if (record != null) {
      final data = await getStore(storeId).record(record).get(db);
      if (data == null) return {};

      return data as Map<String, Object?>;
    }

    final list = await getStore(storeId).find(db);

    return {for (var item in list) item.key: item.value};
  }

  /// update value
  Future<void> set(Stores storeId, Map<String, Object?> data) {
    final sanitizedData = sanitize(data);
    final store = getStore(storeId);

    return db.transaction(
        (txn) => Future.wait(sanitizedData.data.entries.map((entry) {
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

  /// add data into record
  Future<void> add(
    Stores storeId,
    String recordId,
    Map<String, Object?> data,
  ) {
    return getStore(storeId).record(recordId).put(db, data);
  }

  SanitizedData sanitize(Map<String, Object?> data) {
    final sanitizedData = SanitizedData();
    data.forEach(
        (key, value) => sanitizedData.add(_SanitizedValue(key, value)));
    return sanitizedData;
  }
}

class SanitizedData {
  final data = <String, Object?>{};

  void add(_SanitizedValue value) {
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
      data[value.id] = value.data;
      return;
    }

    // only use first setting value
    if (data[value.id] is! Map) {
      return;
    } else if (value.data is! Map) {
      warn('Ignoring different type setting', 'storage.sanitize');
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

class _SanitizedValue {
  late final String id;
  late final Object? data;

  _SanitizedValue(String key, Object? value) {
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
