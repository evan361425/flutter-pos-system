import 'package:flutter/material.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/model_object.dart';
import 'package:possystem/models/repository.dart';
import 'package:possystem/services/database.dart';
import 'package:possystem/services/storage.dart';

abstract class Model<T extends ModelObject> extends ChangeNotifier {
  late String id;

  late String name;

  Model(String? id) : id = id ?? Util.uuidV4();

  String get logName;

  String get prefix => id;

  Repository<Model<T>> get repository;

  set repository(Repository repo);

  void notifyItem() {
    notifyListeners();
    repository.notifyItems();
  }

  Future<void> remove() async {
    info(toString(), '$logName.remove');

    await removeRemotely();

    repository.removeItem(id);
  }

  Future<void> removeRemotely();

  Future<void> save(Map<String, Object?> data);

  T toObject();

  @override
  String toString() => name;

  /// Return `true` if updated any field
  Future<void> update(T object, {String event = 'update'}) async {
    final updateData = object.diff(this);

    if (updateData.isEmpty) return;

    info(toString(), '$logName.$event');

    await save(updateData);

    notifyItem();
  }
}

mixin ModelDB<T extends ModelObject> on Model<T> {
  final String modelTableName = 'table';

  @override
  String get logName => modelTableName;

  @override
  Future<void> removeRemotely() {
    return Database.instance.update(modelTableName, int.parse(id), {
      'isDelete': 1,
    });
  }

  @override
  Future<void> save(Map<String, Object?> data) {
    return Database.instance.update(modelTableName, int.parse(id), data);
  }
}

mixin ModelOrderable<T extends ModelObject> on Model<T> {
  late int index;
}

mixin ModelSearchable<T extends ModelObject> on Model<T> {
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

mixin ModelStorage<T extends ModelObject> on Model<T> {
  final Stores storageStore = Stores.menu;

  @override
  String get logName => storageStore.toString();

  @override
  Future<void> removeRemotely() {
    return save({prefix: null});
  }

  @override
  Future<void> save(Map<String, Object?> data) {
    return Storage.instance.set(storageStore, data);
  }
}
