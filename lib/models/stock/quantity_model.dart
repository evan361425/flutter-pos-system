import 'package:flutter/material.dart';
import 'package:possystem/helper/util.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/services/database.dart';

class QuantityModel {
  final String id;

  String name;

  num defaultProportion;

  QuantityModel({
    String id,
    @required this.name,
    this.defaultProportion = 0,
  }) : id = id ?? Util.uuidV4();

  factory QuantityModel.fromObject(QuantityObject object) => QuantityModel(
        id: object.id,
        name: object.name,
        defaultProportion: object.defaultProportion,
      );

  bool get isNotReady => name == null;

  bool get isReady => name != null;

  String get prefix => id;

  int getSimilarity(String searchText) {
    return Util.similarity(name, searchText);
    // print('$name Similarity to $searchText is $_similarityRating');
  }

  QuantityObject toObject() => QuantityObject(
        id: id,
        name: name,
        defaultProportion: defaultProportion,
      );

  Future<void> update(QuantityObject object) {
    final updateData = object.diff(this);

    if (updateData.isEmpty) return Future.value();

    return Document.instance.update(Collections.quantities, updateData);
  }
}
