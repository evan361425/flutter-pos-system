import 'package:flutter/material.dart';
import 'package:possystem/models/stock/stock_batch_model.dart';
import 'package:possystem/services/database.dart';

class StockBatchRepo extends ChangeNotifier {
  StockBatchRepo() {
    loadFromDb();
  }

  Map<String, StockBatchModel> batches;

  // I/O
  Future<void> loadFromDb() async {
    var snapshot = await Database.service.get(Collections.stock_batch);
    buildFromMap(snapshot.data());
  }

  void buildFromMap(Map<String, dynamic> data) {
    batches = {};
    if (data == null) return;

    try {
      data.forEach((key, value) {
        if (value is Map) {
          batches[key] = StockBatchModel.fromMap(id: key, data: value);
        }
      });
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  // STATE CHANGE

  void updateBatch(StockBatchModel batch) {
    if (hasNotContain(batch.id)) {
      batches[batch.id] = batch;

      final updateData = {batch.id: batch.toMap()};
      Database.service.set(Collections.stock_batch, updateData);
    }
    notifyListeners();
  }

  void removeBatch(String id) {
    batches.remove(id);
    Database.service.update(Collections.stock_batch, {id: null});
    notifyListeners();
  }

  // TOOLS

  bool hasContain(String id) => batches.containsKey(id);
  bool hasNotContain(String id) => !batches.containsKey(id);
  StockBatchModel operator [](String id) => batches[id];

  // GETTER

  bool get isNotReady => batches == null;
  bool get isEmpty => batches.isEmpty;
}
