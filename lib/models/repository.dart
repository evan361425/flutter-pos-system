import 'package:flutter/foundation.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/model.dart';
import 'package:possystem/services/storage.dart';

mixin InitilizableRepository<T extends NotifyModel> on NotifyRepository<T> {
  bool isReady = false;

  T buildModel(String id, Map<String, Object> value);

  Future<void> initialize() {
    return Storage.instance.get(storageStore).then((data) {
      replaceItems({});
      isReady = true;

      data.forEach((id, value) {
        try {
          addItem(buildModel(id, value as Map<String, Object>));
        } catch (e) {
          error(e.toString(), '$itemCode.parse.error');
        }
      });

      notifyListeners();
    }).onError((e, stack) {
      error(e.toString(), '$itemCode.fetch.error');
      throw e!;
    });
  }
}

mixin NotifyRepository<T extends Model> on Repository<T>, ChangeNotifier {
  @override
  void notifyItem() => notifyListeners();
}

mixin OrderablRepository<T extends OrderableModel> on NotifyRepository<T> {
  /// sorted by index
  @override
  List<T> get itemList =>
      items.toList()..sort((a, b) => a.index.compareTo(b.index));

  /// Get highest index of products plus 1
  /// 1-index
  int get newIndex =>
      items.reduce((a, b) => a.index > b.index ? a : b).index + 1;

  Future<void> reorderItems(List<T> items) async {
    final updateData = <String, Object>{};
    var i = 1;

    items.forEach((item) {
      item.index = i++;
      updateData.addAll({'${item.prefix}.index': item.index});
    });

    await Storage.instance.set(storageStore, updateData);

    notifyListeners();
  }
}

mixin Repository<T extends Model> {
  late Map<String, T> _items;

  bool get isEmpty => _items.isEmpty;

  bool get isNotEmpty => _items.isNotEmpty;

  String get itemCode;

  List<T> get itemList => items.toList();

  Iterable<T> get items => _items.values;

  int get length => _items.length;

  Stores get storageStore;

  void addItem(T item) => _items[item.id] = item;

  Future<void> addItemToStorage(T item) {
    return Storage.instance.add(
      storageStore,
      item.id,
      item.toObject().toMap(),
    );
  }

  T? getItem(String id) => _items[id];

  bool hasItem(String id) => _items.containsKey(id);

  void notifyItem();

  /// only remove map value and notify listeners
  /// you should remove item by `item.remove()`
  void removeItem(String id) {
    _items.remove(id);

    notifyItem();
  }

  void replaceItems(Map<String, T> map) => _items = map;

  /// add item if not exist and always notify listeners
  Future<void> setItem(T item) async {
    if (!hasItem(item.id)) {
      info(item.toString(), '$itemCode.add');

      addItem(item);

      await addItemToStorage(item);
    }

    notifyItem();
  }
}

mixin SearchableRepository<T extends SearchableModel> on NotifyRepository<T> {
  List<T> sortBySimilarity(String text) {
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

    final end = similarities.length < 10 ? similarities.length : 10;
    return similarities.sublist(0, end).map((e) => getItem(e.key)!).toList();
  }
}
