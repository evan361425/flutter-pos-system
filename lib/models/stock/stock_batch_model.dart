import 'package:flutter/material.dart';
import 'package:possystem/helper/util.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/repository/stock_model.dart';
import 'package:possystem/services/database.dart';

class StockBatchModel {
  String name;

  final String id;

  final Map<String, num> data;

  StockBatchModel({
    @required this.name,
    id,
    Map<String, num> data,
  })  : id = id ?? Util.uuidV4(),
        data = data ?? {};

  factory StockBatchModel.fromObject(StockBatchObject object) =>
      StockBatchModel(
        id: object.id,
        name: object.name,
        data: object.data,
      );

  String get prefix => id;

  num operator [](String id) => data[id];

  void apply() => StockModel.instance.applyAmounts(data);

  bool hasNot(String id) => !data.containsKey(id);

  Map<String, dynamic> toMap() => {
        'name': name,
        'data': data,
      };

  Future<void> update(StockBatchObject object) {
    final updateData = object.diff(this);

    if (updateData.isEmpty) return Future.value();

    return Document.instance.update(Collections.stock_batch, updateData);
  }
}
