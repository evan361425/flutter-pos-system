import 'dart:math';

import 'package:flutter/material.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/stock/quantity_model.dart';
import 'package:possystem/services/database.dart';

class QuantityRepo extends ChangeNotifier {
  static final QuantityRepo _instance = QuantityRepo._constructor();

  static QuantityRepo get instance => _instance;

  Map<String, QuantityModel> quantities;

  QuantityRepo._constructor() {
    Database.instance.get(Collections.quantities).then((snapsnot) {
      quantities = {};

      final data = snapsnot.data();
      if (data == null) return;

      try {
        data.forEach((id, map) {
          quantities[id] = QuantityModel.fromObject(
            QuantityObject.build({'id': id, ...map}),
          );
        });
      } catch (e) {
        print(e);
      }

      notifyListeners();
    });
  }

  bool get isEmpty => quantities.isEmpty;

  bool get isNotReady => quantities == null;

  bool get isReady => quantities != null;

  List<QuantityModel> get quantitiesList => quantities.values.toList();

  QuantityModel operator [](String id) =>
      quantities[id] ?? quantities.values.first;

  bool hasContain(String id) => quantities.containsKey(id);

  Future<void> removeQuantity(QuantityModel quantity) {
    quantities.remove(quantity.id);

    notifyListeners();

    return Database.instance.update(Collections.quantities, {
      quantity.prefix: null,
    });
  }

  void updateQuantity(QuantityModel quantity) {
    if (!hasContain(quantity.id)) {
      quantities[quantity.id] = quantity;

      final updateData = {'${quantity.id}': quantity.toObject().toMap()};

      Database.instance.set(Collections.quantities, updateData);
    }

    notifyListeners();
  }

  List<QuantityModel> sortBySimilarity(String text) {
    if (text.isEmpty) {
      return [];
    }

    final similarities = quantities.entries
        .map((e) => MapEntry(e.key, e.value.getSimilarity(text)))
        .where((e) => e.value > 0)
        .toList();
    similarities.sort((ing1, ing2) {
      // if ing1 < ing2 return -1 will make ing1 be the first one
      if (ing1.value == ing2.value) return 0;
      return ing1.value < ing2.value ? 1 : -1;
    });

    final end = min(10, similarities.length);
    return similarities.sublist(0, end).map((e) => quantities[e.key]);
  }
}
