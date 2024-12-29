import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/model.dart';
import 'package:possystem/services/storage.dart';

mixin Repository<T extends Model> on ChangeNotifier {
  Map<String, T> _items = {};

  /// Use for importing items
  final Map<String, T> _stagedItems = {};

  bool get isEmpty => _items.isEmpty;

  bool get isNotEmpty => _items.isNotEmpty;

  List<T> get itemList => items.toList();

  Iterable<T> get items => _items.values;

  int get length => _items.length;

  Iterable<T> get stagedItems => _stagedItems.values;

  /// Abort the data not saved in file system
  ///
  /// This is used to import/export data.
  void abortStaged() {
    _stagedItems.clear();
  }

  Future<void> addItem(T item, {bool save = true}) async {
    if (!save) {
      item.repository = this;
      _items[item.id] = item;
      return;
    }

    if (!hasItem(item.id)) {
      item.repository = this;

      await saveItem(item);

      _items[item.id] = item;

      notifyItems();
    }
  }

  void addStaged(T item) {
    _stagedItems[item.id] = item;
  }

  /// Commit the staged data to the file system
  ///
  /// [save] whether to save the data to the file system
  /// [reset] whether to clear the original data and use staged data to replace it
  ///
  /// It is use for import/export data
  Future<void> commitStaged({bool save = true, bool reset = true}) async {
    if (reset) {
      _items.clear();
      if (save) {
        await dropItems();
      }
    }

    for (var item in stagedItems) {
      if (save) {
        await saveItem(item);
      }
      item.status = ModelStatus.normal;
      _items[item.id] = item;
    }

    _stagedItems.clear();

    notifyItems();
  }

  T? getItem(String id) => _items[id];

  T? getItemByName(String name) {
    for (var item in items) {
      if (item.name == name) {
        return item;
      }
    }
    return null;
  }

  T? getStaged(String id) {
    for (var item in stagedItems) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  T? getStagedByName(String name) {
    for (var item in stagedItems) {
      if (item.name == name) {
        return item;
      }
    }
    return null;
  }

  bool hasItem(String id) => _items.containsKey(id);

  bool hasName(String name) => items.any((item) => item.name == name);

  void notifyItems() => notifyListeners();

  void prepareItem() {
    for (var item in items) {
      item.repository = this;
    }
  }

  /// only remove map value and notify listeners
  /// you should remove item by `item.remove()`
  void removeItem(String id) {
    _items.remove(id);
    notifyItems();
  }

  void replaceItems(Map<String, T> map) => _items = map;

  Future<void> saveBatch(Iterable<RepositoryBatchData> data);

  Future<void> saveItem(T item);

  Future<void> dropItems();
}

mixin RepositoryOrderable<T extends ModelOrderable> on Repository<T> {
  /// sorted by index
  @override
  List<T> get itemList => items.sorted((a, b) => a.index.compareTo(b.index));

  /// Get highest index of products plus 1
  /// 1-index
  int get newIndex => isEmpty ? 1 : items.reduce((a, b) => a.index > b.index ? a : b).index + 1;

  Future<void> reorderItems(List<T> items) async {
    var i = 0;
    final data = items
        .where((item) {
          if (item.index != ++i) {
            item.index = i;
            return true;
          } else {
            return false;
          }
        })
        .map<RepositoryBatchData>((item) => RepositoryBatchData(id: item.prefix, key: 'index', value: item.index))
        .toList();

    if (data.isNotEmpty) {
      Log.ger('reorder_items', {'type': items.first.logName, 'length': data.length});
      await saveBatch(data);

      notifyItems();
    }
  }
}

mixin RepositorySearchable<T extends ModelSearchable> on Repository<T> {
  List<T> sortBySimilarity(String text, {int limit = 10}) {
    final similarities = items.map((e) => MapEntry(e.id, e.getSimilarity(text))).where((e) => e.value > 0).toList();
    similarities.sort((ing1, ing2) {
      // if ing1 < ing2 return -1 will make ing1 be the first one
      if (ing1.value == ing2.value) return 0;
      return ing1.value < ing2.value ? 1 : -1;
    });

    final end = similarities.length < limit ? similarities.length : limit;
    return similarities.sublist(0, end).map((e) => getItem(e.key)!).toList();
  }
}

mixin RepositoryStorage<T extends Model> on Repository<T> {
  bool versionChanged = false;

  RepositoryStorageType get repoType => RepositoryStorageType.pureRepo;

  Stores get storageStore;

  T buildItem(String id, Map<String, Object?> value);

  Future<void> initialize({String? record}) async {
    try {
      final data = await Storage.instance.get(storageStore, record);

      data.forEach((id, value) {
        try {
          final item = buildItem(id, value as Map<String, Object?>);
          _items[item.id] = item;
        } catch (e, stack) {
          Log.err(e, '${storageStore.name}_parse_error', stack);
        }
      });

      prepareItem();

      if (versionChanged) {
        Log.ger('upgrade_items', {'type': storageStore.name, 'length': _items.length});
        await Storage.instance.setAll(storageStore, {
          for (final item in _items.values) item.prefix: item.toObject().toMap(),
        });
      }
    } catch (e, stack) {
      Log.err(e, '${storageStore.name}_fetch_error', stack);
    }
  }

  @override
  Future<void> saveBatch(Iterable<RepositoryBatchData> data) {
    return Storage.instance.set(storageStore, {
      for (final item in data) '${item.id}.${item.key}': item.value,
    });
  }

  @override
  Future<void> saveItem(T item) {
    Log.ger('add_item', {'type': storageStore.name, 'name': item.toString()});

    final data = item.toObject().toMap();
    return repoType == RepositoryStorageType.pureRepo
        ? Storage.instance.add(storageStore, item.id, data)
        : Storage.instance.set(storageStore, {item.prefix: data});
  }

  @override
  Future<void> dropItems() {
    if (repoType == RepositoryStorageType.repoModel) return Future.value();

    return Storage.instance.reset(storageStore);
  }
}

enum RepositoryStorageType {
  pureRepo,
  repoModel,
  repoProperties,
}

class RepositoryBatchData {
  final String id;
  final String key;
  final Object? value;
  const RepositoryBatchData({required this.id, required this.key, this.value});
}
