import 'package:flutter/material.dart';
import 'package:possystem/helper/util.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/repository/stock_batch_repo.dart';
import 'package:possystem/models/repository/stock_model.dart';
import 'package:possystem/services/storage.dart';

class StockBatchModel {
  final String id;

  String name;

  // ingredient id => add number
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
  num getNumOfId(String id) => exist(id) ? data[id] : null;

  void apply() => StockModel.instance.applyAmounts(data);

  bool exist(String id) => data.containsKey(id);

  StockBatchObject toObject() => StockBatchObject(
        id: id,
        name: name,
        data: data,
      );

  Future<void> remove() async {
    await Storage.instance.set(Stores.quantities, {prefix: null});

    StockBatchRepo.instance.removeBatch(id);
  }

  Future<void> update(StockBatchObject object) {
    final updateData = object.diff(this);

    if (updateData.isEmpty) return Future.value();

    return Storage.instance.set(Stores.stock_batch, updateData);
  }
}
