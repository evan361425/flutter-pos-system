import 'package:flutter/material.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/stock/stock_batch_model.dart';
import 'package:possystem/services/database.dart';

class StockBatchRepo extends ChangeNotifier {
  static final StockBatchRepo _instance = StockBatchRepo._constructor();

  static StockBatchRepo get instance => _instance;

  Map<String, StockBatchModel> batches;

  StockBatchRepo._constructor() {
    Document.instance.get(Collections.stock_batch).then((snapsnot) {
      batches = {};

      final data = snapsnot.data();
      if (data != null) {
        try {
          data.forEach((id, map) {
            batches[id] = StockBatchModel.fromObject(
              StockBatchObject.build({'id': id, ...map}),
            );
          });
        } catch (e, stack) {
          print(e);
          print(stack);
        }
      }

      notifyListeners();
    });
  }

  bool get isEmpty => batches.isEmpty;

  bool get isNotReady => batches == null;

  StockBatchModel operator [](String id) => batches[id];

  bool hasContain(String id) => batches.containsKey(id);

  Future<void> removeBatch(String id) {
    batches.remove(id);

    notifyListeners();

    return Document.instance.update(Collections.stock_batch, {id: null});
  }

  void updateBatch(StockBatchModel batch) {
    if (!hasContain(batch.id)) {
      batches[batch.id] = batch;

      final updateData = {batch.id: batch.toMap()};

      Document.instance.set(Collections.stock_batch, updateData);
    }

    notifyListeners();
  }
}
