import 'package:flutter/material.dart';
import 'package:possystem/models/stock/quantity_model.dart';
import 'package:possystem/services/database.dart';

class QuantityRepo extends ChangeNotifier {
  static final QuantityRepo _instance = QuantityRepo._constructor();

  static QuantityRepo get instance => _instance;

  QuantityRepo._constructor() {
    loadFromDb();
  }

  Map<String, QuantityModel> quantities;

  // I/O
  Future<void> loadFromDb() async {
    var snapshot = await Database.instance.get(Collections.quantities);
    buildFromMap(snapshot.data());
  }

  void buildFromMap(Map<String, dynamic> data) {
    quantities = {};
    if (data == null) {
      notifyListeners();
      return;
    }

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

  void updateQuantity(QuantityModel quantity) {
    if (hasNotContain(quantity.id)) {
      quantities[quantity.id] = quantity;

      final updateData = {'${quantity.id}': quantity.toMap()};
      Database.instance.set(Collections.quantities, updateData);
    }

    notifyListeners();
  }

  void removeQuantity(String id) {
    quantities.remove(id);
    Database.instance.update(Collections.quantities, {id: null});
    notifyListeners();
  }

  // TOOLS

  bool hasContain(String id) => quantities.containsKey(id);
  bool hasNotContain(String id) => !quantities.containsKey(id);
  QuantityModel operator [](String id) =>
      quantities[id] ?? quantities.values.first;

  // GETTER

  List<QuantityModel> get quantitiesList => quantities.values.toList();
  bool get isReady => quantities != null;
  bool get isNotReady => quantities == null;
  bool get isEmpty => quantities.isEmpty;
}
