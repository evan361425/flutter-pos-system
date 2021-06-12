import 'package:flutter/material.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/model_object.dart';
import 'package:possystem/services/storage.dart';

mixin Model<T extends ModelObject> {
  late String id;

  String get code;
  Stores get storageStore;
  String get prefix => id;

  void removeFromRepo();

  T toObject();

  Future<void> update(T object);

  Future<void> remove() async {
    info(toString(), '$code.remove');
    await Storage.instance.set(storageStore, {prefix: null});

    removeFromRepo();
  }
}

abstract class NotifyModel<T extends ModelObject> extends ChangeNotifier
    with Model<T> {
  @override
  late final String id;

  NotifyModel(String? id) {
    this.id = id ?? Util.uuidV4();
  }

  @override
  Future<void> update(T object) async {
    final updateData = object.diff(this);

    if (updateData.isEmpty) return Future.value();

    info(toString(), '$code.update');
    notifyListeners();

    return Storage.instance.set(storageStore, updateData);
  }
}

mixin OrderableModel<T extends ModelObject> on NotifyModel<T> {
  late int index;
}

mixin SearchableModel<T extends ModelObject> on NotifyModel<T> {
  late String name;

  /// get similarity between [name] and [pattern]
  int getSimilarity(String pattern) {
    final found = name.split(' ').where((e) => e.startsWith(pattern)).length;
    var score = found == 0
        ? name.contains(pattern)
            ? 1
            : 0
        : found * 2;

    return score;
  }
}
