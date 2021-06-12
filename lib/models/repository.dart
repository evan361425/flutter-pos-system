import 'package:flutter/foundation.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/model.dart';
import 'package:possystem/services/storage.dart';

mixin Repository<T extends Model> on ChangeNotifier {
  late Map<String, T> childMap;

  String get childCode;

  Iterable<T> get childs => childMap.values;

  bool get isEmpty => childMap.isEmpty;

  bool get isNotEmpty => childMap.isNotEmpty;

  int get length => childMap.length;

  Stores get storageStore;

  List<T> get childList => childs.toList();

  bool existChild(String id) => childMap.containsKey(id);

  T? getChild(String id) => childMap[id];

  /// only remove map value and notify listeners
  /// you should remove child by `child.remove()`
  void removeChild(String id) {
    childMap.remove(id);

    notifyListeners();
  }

  /// add child if not exist and always notify listeners
  Future<void> setChild(T child) async {
    if (!existChild(child.id)) {
      info(child.toString(), '$childCode.add');
      childMap[child.id] = child;

      final updateData = child.toObject().toMap();

      await Storage.instance.add(storageStore, child.id, updateData);
    }

    notifyListeners();
  }
}

mixin OrderablRepository<T extends OrderableModel> on Repository<T> {
  Future<void> reorderChilds(List<T> childs) async {
    final updateData = <String, Object>{};
    var i = 1;

    childs.forEach((child) {
      child.index = i++;
      updateData.addAll({'${child.prefix}.index': child.index});
    });

    await Storage.instance.set(storageStore, updateData);

    notifyListeners();
  }

  /// sorted by index
  @override
  List<T> get childList =>
      childs.toList()..sort((a, b) => a.index.compareTo(b.index));

  /// Get highest index of products plus 1
  /// 1-index
  int get newIndex =>
      childs.reduce((a, b) => a.index > b.index ? a : b).index + 1;
}

mixin InitilizableRepository<T extends Model> on Repository<T> {
  bool isReady = false;

  Future<void> initialize() {
    return Storage.instance.get(storageStore).then((data) {
      childMap = {};
      isReady = true;

      data.forEach((id, value) {
        try {
          childMap[id] = buildModel(id, value as Map<String, Object>);
        } catch (e) {
          error(e.toString(), '$childCode.parse.error');
        }
      });

      notifyListeners();
    }).onError((e, stack) {
      error(e.toString(), '$childCode.fetch.error');
      throw e!;
    });
  }

  T buildModel(String id, Map<String, Object> value);
}

mixin SearchableRepository<T extends SearchableModel> on Repository<T> {
  List<T> sortBySimilarity(String text) {
    if (text.isEmpty) {
      return [];
    }

    final similarities = childMap.entries
        .map((e) => MapEntry(e.key, e.value.getSimilarity(text)))
        .where((e) => e.value > 0)
        .toList();
    similarities.sort((ing1, ing2) {
      // if ing1 < ing2 return -1 will make ing1 be the first one
      if (ing1.value == ing2.value) return 0;
      return ing1.value < ing2.value ? 1 : -1;
    });

    final end = similarities.length < 10 ? similarities.length : 10;
    return similarities.sublist(0, end).map((e) => getChild(e.key)!).toList();
  }
}
