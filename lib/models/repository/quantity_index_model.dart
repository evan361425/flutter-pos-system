import 'package:flutter/material.dart';
import 'package:possystem/models/stock/quantity_model.dart';
import 'package:possystem/services/database.dart';

class QuantityIndexModel extends ChangeNotifier {
  QuantityIndexModel() {
    loadFromDb();
  }

  Map<String, QuantityModel> quantities;

  // I/O
  Future<void> loadFromDb() async {
    var snapshot = await Database.service.get(Collections.quantities);
    buildFromMap(snapshot.data());
  }

  void buildFromMap(Map<String, dynamic> data) {
    quantities = {};
    if (data == null) return;

    try {
      data.forEach((key, value) {
        if (value is Map) {
          quantities[key] = QuantityModel.fromMap(id: key, data: value);
        }
      });
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  void addQuantity(QuantityModel quantity) {
    quantities[quantity.id] = quantity;

    final updateData = {'${quantity.id}': quantity.toMap()};
    Database.service.set(Collections.quantities, updateData);
  }

  void removeQuantity(String id) {
    quantities.remove(id);
    Database.service.update(Collections.quantities, {id: null});
    notifyListeners();
  }

  // TOOLS

  bool hasContain(String id) {
    return quantities.containsKey(id);
  }

  // GETTER

  QuantityModel operator [](String id) {
    return quantities[id];
  }

  bool get isNotReady => quantities == null;
  bool get isEmpty => quantities.isEmpty;
}
