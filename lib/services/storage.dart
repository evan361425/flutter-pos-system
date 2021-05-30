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

  late Database db;

  Storage._constructor();

  Future<void> initialize() async {
    final path = await getDatabasesPath();
    final dbPath = join(path, 'pos_system.sembast');
    db = await databaseFactoryIo.openDatabase(dbPath);
  }

  StoreRef getStore(Stores storeId) {
    return stringMapStoreFactory.store(storeId.toString());
  }

  Future<Map<String, Object>> get(Stores storeId) async {
    final list = await getStore(storeId).find(db);

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
  Future<void> set(Stores storeId, Map<String, Object?> data) async {
    final refactorized = <String, Map<String, Object?>?>{};

    data.entries.forEach(
      (item) => _SanitizedValues.parse(item).addTo(refactorized),
    );

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
    final value =
        index == -1 ? item.value as Map<String, Object?> : {key: item.value};

    return _SanitizedValues(id: id, value: value);
  }
}
