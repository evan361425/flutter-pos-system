import 'package:flutter/material.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/stock/stock_batch_model.dart';
import 'package:possystem/services/storage.dart';

class StockBatchRepo extends ChangeNotifier {
  static late StockBatchRepo instance;

  Map<String, StockBatchModel>? batches;

  StockBatchRepo() {
    Storage.instance.get(Stores.stock_batch).then((data) {
      batches = {};

      try {
        data.forEach((id, value) {
          if (value is Map) {
            batches![id] = StockBatchModel.fromObject(
              StockBatchObject.build(
                  {'id': id, ...value as Map<String, Object?>}),
            );
          }
        });
      } catch (e, stack) {
        print(e);
        print(stack);
      }

      notifyListeners();
    });
    StockBatchRepo.instance = this;
  }

  bool get isEmpty => batches!.isEmpty;
  bool get isNotEmpty => batches!.isNotEmpty;
  bool get isReady => batches != null;
  bool get isNotReady => batches == null;
  int get length => batches!.length;

  StockBatchModel? getBatch(String? id) => exist(id) ? batches![id!] : null;

  bool exist(String? id) => batches!.containsKey(id);
  bool hasBatch(String name) => !batches!.values.every((e) => e.name != name);

  void removeBatch(String id) {
    batches!.remove(id);

    notifyListeners();
  }

  void updateBatch(StockBatchModel batch) {
    if (!exist(batch.id)) {
      batches![batch.id] = batch;

      Storage.instance.add(
        Stores.stock_batch,
        batch.id,
        batch.toObject().toMap(),
      );
    }

    notifyListeners();
  }
}
