import 'package:flutter/material.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/repository.dart';
import 'package:possystem/models/stock/stock_batch_model.dart';
import 'package:possystem/services/storage.dart';

class StockBatchRepo extends ChangeNotifier
    with
        Repository<StockBatchModel>,
        NotifyRepository<StockBatchModel>,
        InitilizableRepository {
  static late StockBatchRepo instance;

  StockBatchRepo() {
    initialize();

    StockBatchRepo.instance = this;
  }

  @override
  String get itemCode => 'stock.batch';

  @override
  Stores get storageStore => Stores.stock_batch;

  @override
  StockBatchModel buildModel(String id, Map<String, Object?> value) {
    return StockBatchModel.fromObject(
      StockBatchObject.build({
        'id': id,
        ...value,
      }),
    );
  }

  bool hasBatch(String name) => !items.every((e) => e.name != name);
}
