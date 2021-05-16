import 'package:flutter/material.dart';
import 'package:possystem/helper/util.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/repository/quantity_repo.dart';
import 'package:possystem/services/storage.dart';

class QuantityModel {
  final String id;

  // quantity name: less, more, ...
  String name;

  // between 0 ~ 1
  num defaultProportion;

  QuantityModel({
    String id,
    @required this.name,
    num defaultProportion,
  })  : id = id ?? Util.uuidV4(),
        defaultProportion = defaultProportion ?? 1;

  factory QuantityModel.fromObject(QuantityObject object) => QuantityModel(
        id: object.id,
        name: object.name,
        defaultProportion: object.defaultProportion,
      );

  bool get isNotReady => name == null;
  bool get isReady => name != null;

  String get prefix => id;

  int getSimilarity(String searchText) => Util.similarity(name, searchText);

  Future<void> remove() async {
    print('Remove quantity $name');
    await Storage.instance.set(Stores.stock, {prefix: null});

    return QuantityRepo.instance.removeQuantity(prefix);
  }

  QuantityObject toObject() => QuantityObject(
        id: id,
        name: name,
        defaultProportion: defaultProportion,
      );

  Future<void> update(QuantityObject object) {
    final updateData = object.diff(this);

    if (updateData.isEmpty) return Future.value();

    return Storage.instance.set(Stores.quantities, updateData);
  }
}
