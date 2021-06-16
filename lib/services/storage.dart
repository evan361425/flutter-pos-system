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
  static Storage instance = Storage();

  late final Database db;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    final databasePath = await getDatabasesPath() + '/pos_system.sembast';
    db = await databaseFactoryIo.openDatabase(databasePath);

    _initialized = true;
  }

  /// Get string map Store
  ///
  /// variable to make it easy to test
  static StoreRef getStore(Stores storeId) =>
      stringMapStoreFactory.store(storeId.toString());

  Future<Map<String, Object>> get(Stores storeId) async {
    final list = await getStore(storeId).find(db);

    return {for (var item in list) item.key: item.value};
  }

  /// update value
  Future<void> set(Stores storeId, Map<String, Object?> data) async {
    final refactorized = <String, Map<String, Object?>?>{};
    data.entries.forEach((item) => sanitize(item, refactorized));

    final store = getStore(storeId);
    return db.transaction(
      (txn) => Future.wait([
        for (var item in refactorized.entries)
          item.value == null
              ? store.record(item.key).delete(txn)
              : store.record(item.key).update(txn, item.value!)
      ]),
    );
  }

  Future<void> add(
    Stores storeId,
    String recordId,
    Map<String, Object?> data,
  ) {
    return getStore(storeId).record(recordId).put(db, data);
  }

  /// Parse first part of key as ID
  ///
  /// ```dart
  /// result = <String, Map<String, Object?>?>{};
  /// data = {
  ///   'some-id.a': null,
  ///   'some-id.b.c': {
  ///     'a': 'b',
  ///     'c': {
  ///       'd': 'e'
  ///     }
  ///   },
  ///   'some-id.d.e': 'f',
  ///   'some-id.g': {
  ///     'h': null
  ///   }
  /// };
  /// data.entries.forEach((item) => storage.sanitize(item, result));
  /// result == {
  ///   'some-id': {
  ///     'a': null,
  ///     'b.c': {
  ///       'a': 'b',
  ///       'c': {
  ///         'd': 'e'
  ///       }
  ///     },
  ///     'd.e': 'f',
  ///     'g': {
  ///       'h': null
  ///     }
  ///   }
  /// }
  /// ```
  void sanitize(
    MapEntry<String, Object?> item,
    Map<String, Map<String, Object?>?> result,
  ) {
    _SanitizedValues.parse(item).addTo(result);
  }
}

class UpdatedData {
  final data = <String, Map<String, Object>?>{};

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
      data[value.id] = <String, Object>{};
    }
  }
}

class _SanitizedValue {
  late final String id;
  late final Map<String, Object>? data;

  _SanitizedValue(String key, Object? value) {
    final index = key.indexOf('.');
    final keyIsID = index == -1;
    id = keyIsID ? key : key.substring(0, index);

    if (keyIsID) {
      if (value != null) {
        assert(value is Map, 'when updating root object, value must be map.');
        data = value as Map<String, Object>;
      }
    } else {
      assert(!(value is Map), 'not allow deep map, try using dot key.');
      final entry = _parseDotKey(key.substring(index + 1), value);
      data = {entry.key: entry.value};
    }
  }

  MapEntry<String, Object> _parseDotKey(String key, Object? value) {
    final data = <String, Object>{};
    late Map<String, Object> last;
    var current = data;

    key.split('.').forEach((k) {
      if (current[k] == null) {
        current[k] = <String, Object>{};
        last = current;
        current = current[k] as Map<String, Object>;
      }
    });

    last[key.substring(key.lastIndexOf('.') + 1)] = value ?? FieldValue.delete;
    return data.entries.first;
  }
}

class _SanitizedValues {
  final String id;
  final Map<String, Object?>? value;

  const _SanitizedValues({required this.id, this.value});

  void addTo(Map<String, Map<String, Object?>?> map) {
    // use contains key, since value might be null
    if (map.containsKey(id)) {
      // null will delete the record
      if (value == null) {
        map[id] = null;
      } else if (map[id] != null) {
        map[id] = {...map[id]!, ...value!};
      }
    } else {
      map[id] = value;
    }
  }

  factory _SanitizedValues.parse(MapEntry<String, Object?> item) {
    final index = item.key.indexOf('.');
    final id = index == -1 ? item.key : item.key.substring(0, index);
    final key = item.key.substring(index + 1);

    // delete root record
    if (item.value == null && index == -1) {
      return _SanitizedValues(id: id);
    }

    // make sure value be map if updating root object
    // index != -1: update subclass
    assert(
      index != -1 || item.value is Map,
      'when updating root object, value must be map. example: {id: mapValue}',
    );

    // set to map value
    final value = index == -1
        ? item.value as Map<String, Object?>
        : {key: item.value ?? FieldValue.delete};

    return _SanitizedValues(id: id, value: value);
  }
}
