import 'package:flutter/material.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/model_object.dart';
import 'package:possystem/services/database.dart';
import 'package:possystem/services/storage.dart';

mixin DBModel<T extends ModelObject> on Model<T> {
  String get tableName;

  @override
  Future<void> remove() async {
    info(toString(), '$logCode.remove');
    await Database.instance.delete(tableName, id);

    removeFromRepo();
  }

  @override
  Future<void> update(object, {String event = 'update'}) async {
    final updateData = object.diff(this);

    if (updateData.isEmpty) return;

    info(toString(), '$logCode.$event');

    // should update id to `int` type in future
    await updateItemToDB(updateData);

    handleUpdated();
  }

  Future<void> updateItemToDB(Map<String, Object?> data) {
    return Database.instance.update(tableName, int.parse(id), data);
  }
}

mixin Model<T extends ModelObject> {
  late String id;

  late String name;

  final String logCode = 'model';

  final Stores storageStore = Stores.menu;

  String get prefix => id;

  String generateId() => Util.uuidV4();

  void handleUpdated() {}

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
  Future<void> update(T object, {String event = 'update'}) async {
    final updateData = object.diff(this);

    if (updateData.isEmpty) return;

    info(toString(), '$logCode.$event');

    await Storage.instance.set(storageStore, updateData);

    handleUpdated();
  }
}

abstract class NotifyModel<T extends ModelObject> extends ChangeNotifier
    with Model<T> {
  NotifyModel(String? id) {
    this.id = id ?? generateId();
  }

  @override
  void handleUpdated() {
    notifyItem();
  }

  void notifyItem() => notifyListeners();
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
