import 'package:flutter/material.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/model_object.dart';
import 'package:possystem/services/storage.dart';

mixin Model<T extends ModelObject> {
  late String id;

  late String name;

  final String logCode = 'model';

  final Stores storageStore = Stores.menu;

  String get prefix => id;

  Future<void> remove() async {
    info(toString(), '$logCode.remove');
    await Storage.instance.set(storageStore, {prefix: null});

    removeFromRepo();
  }

  void removeFromRepo();

  T toObject();

  @override
  String toString() => name;

  /// Return `true` if updated any field
  Future<bool> update(T object, {String event = 'update'}) async {
    final updateData = object.diff(this);

    if (updateData.isEmpty) return false;

    info(toString(), '$logCode.$event');

    await Storage.instance.set(storageStore, updateData);

    return true;
  }
}

abstract class NotifyModel<T extends ModelObject> extends ChangeNotifier
    with Model<T> {
  @override
  late final String id;

  NotifyModel(String? id) : id = id ?? Util.uuidV4();

  @override
  Future<bool> update(T object, {String event = 'update'}) async {
    final isUpdated = await super.update(object, event: event);

    if (isUpdated) notifyListeners();

    return isUpdated;
  }
}

mixin OrderableModel<T extends ModelObject> on Model<T> {
  late int index;
}

mixin SearchableModel<T extends ModelObject> on Model<T> {
  /// get similarity between [name] and [pattern]
  int getSimilarity(String pattern) {
    final name = this.name.toLowerCase();
    pattern = pattern.toLowerCase();

    final score = name.split(' ').fold<int>(0, (value, e) {
      final addition = e.startsWith(pattern)
          ? 2
          : e.contains(pattern)
              ? 1
              : 0;
      return value + addition;
    });

    return score;
  }
}
