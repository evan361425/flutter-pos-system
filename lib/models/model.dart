import 'package:flutter/material.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/model_object.dart';
import 'package:possystem/services/storage.dart';

abstract class Model<T extends ModelObject> extends ChangeNotifier {
  final String id;

  Model(String? id) : id = id ?? Util.uuidV4();
  String get code;
  Stores get storageStore;
  String get prefix => id;

  void removeFromRepo();

  T toObject();

  Future<void> update(T object) async {
    final updateData = object.diff(this);

    if (updateData.isEmpty) return Future.value();

    info(toString(), '$code.update');
    notifyListeners();

    return Storage.instance.set(storageStore, updateData);
  }

  Future<void> remove() async {
    info(toString(), '$code.remove');
    await Storage.instance.set(storageStore, {prefix: null});

    removeFromRepo();
  }
}

mixin OrderableModel<T extends ModelObject> on Model<T> {
  late int index;
}
