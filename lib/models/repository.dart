import 'package:flutter/foundation.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/model.dart';
import 'package:possystem/services/database.dart';
import 'package:possystem/services/storage.dart';

mixin Repository<T extends Model> on ChangeNotifier {
  Map<String, T> _items = {};

  bool get isEmpty => _items.isEmpty;

  bool get isNotEmpty => _items.isNotEmpty;

  List<T> get itemList => items.toList();

  Iterable<T> get items => _items.values;

  int get length => _items.length;

  Future<void> addItem(T item) async {
    if (!hasItem(item.id)) {
      item.repository = this;
      await saveItem(item);

      _items[item.id] = item;

      notifyItems();
    }
  }

  T? getItem(String id) => _items[id];

  bool hasItem(String id) => _items.containsKey(id);

  bool hasName(String name) => items.any((item) => item.name == name);

  void notifyItems() => notifyListeners();

  void prepareItem() => items.forEach((item) => item.repository = this);

  /// only remove map value and notify listeners
  /// you should remove item by `item.remove()`
  void removeItem(String id) {
    _items.remove(id);
    notifyItems();
  }

  void replaceItems(Map<String, T> map) => _items = map;

  Future<void> saveBatch(Iterable<_BatchData> data);

  Future<void> saveItem(T item);
}

mixin RepositoryDB<T extends Model> on Repository<T> {
  final String idName = 'id';

  final String repoTableName = '';

  Future<T> buildItem(Map<String, Object?> value);

  Future<List<Map<String, Object?>>> fetchItems() {
    return Database.instance.query(
      repoTableName,
      where: 'isDelete = ?',
      whereArgs: [0],
    );
  }

  Future<void> initialize() async {
    try {
      final items = await fetchItems();

      for (final itemData in items) {
        try {
          final item = await buildItem(itemData);
          _items[item.id] = item;
        } catch (e, stack) {
          await error(e.toString(), 'db.$repoTableName.parse.error', stack);
        }
      }

      prepareItem();
    } catch (e, stack) {
      print(stack);
      await error(e.toString(), 'db.$repoTableName.fetch.error', stack);
    }
  }

  @override
  Future<void> saveBatch(Iterable<_BatchData> data) {
    return Database.instance.batchUpdate(
      repoTableName,
      data.map((e) => {e.key: e.value}).toList(),
      where: '$idName = ?',
      whereArgs: data.map((e) => [e.id]).toList(),
    );
  }

  @override
  Future<void> saveItem(T item) async {
    info(item.toString(), '$repoTableName.add');

    final id = await Database.instance.push(
      repoTableName,
      item.toObject().toMap(),
    );

    item.id = id.toString();
  }
}

mixin RepositoryOrderable<T extends ModelOrderable> on Repository<T> {
  /// sorted by index
  @override
  List<T> get itemList =>
      items.toList()..sort((a, b) => a.index.compareTo(b.index));

  /// Get highest index of products plus 1
  /// 1-index
  int get newIndex =>
      isEmpty ? 1 : items.reduce((a, b) => a.index > b.index ? a : b).index + 1;

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
        .map<_BatchData>((item) =>
            _BatchData(id: item.prefix, key: 'index', value: item.index))
        .toList();

    if (data.isNotEmpty) {
      info(data.length.toString(), '${items.first.logName}.reorder');
      await saveBatch(data);

      notifyItems();
    }
  }
}

mixin RepositorySearchable<T extends ModelSearchable> on Repository<T> {
  List<T> sortBySimilarity(String text, {int limit = 10}) {
    if (text.isEmpty) {
      return [];
    }

    final similarities = items
        .map((e) => MapEntry(e.id, e.getSimilarity(text)))
        .where((e) => e.value > 0)
        .toList();
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

  final Stores storageStore = Stores.menu;

  final RepositoryStorageType repoType = RepositoryStorageType.PureRepo;

  T buildItem(String id, Map<String, Object?> value);

  Future<void> initialize() async {
    try {
      final data = await Storage.instance.get(storageStore);

      data.forEach((id, value) {
        try {
          final item = buildItem(id, value as Map<String, Object?>);
          _items[item.id] = item;
        } catch (e, stack) {
          error(e.toString(), '$storageStore.parse.error', stack);
        }
      });

      prepareItem();

      if (versionChanged) {
        info(_items.toString(), '$storageStore.upgrade');
        await Storage.instance.setAll(storageStore, {
          for (final item in _items.values)
            item.prefix: item.toObject().toMap(),
        });
      }
    } catch (e, stack) {
      print(stack);
      await error(e.toString(), '$storageStore.fetch.error', stack);
    }
  }

  @override
  Future<void> saveBatch(Iterable<_BatchData> data) {
    return Storage.instance.set(storageStore, {
      for (final item in data) '${item.id}.${item.key}': item.value,
    });
  }

  @override
  Future<void> saveItem(T item) {
    info(item.toString(), '$storageStore.add');

    final data = item.toObject().toMap();
    return repoType == RepositoryStorageType.PureRepo
        ? Storage.instance.add(storageStore, item.id, data)
        : Storage.instance.set(storageStore, {item.prefix: data});
  }
}

enum RepositoryStorageType {
  PureRepo,
  RepoModel,
}

class _BatchData {
  final String id;
  final String key;
  final Object? value;
  const _BatchData({required this.id, required this.key, this.value});
}
