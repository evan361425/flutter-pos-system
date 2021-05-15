import 'dart:math';

import 'package:flutter/material.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/stock/quantity_model.dart';
import 'package:possystem/services/storage.dart';

class QuantityRepo extends ChangeNotifier {
  static final QuantityRepo _instance = QuantityRepo._constructor();

  static QuantityRepo get instance => _instance;

  Map<String, QuantityModel> quantities;

  QuantityRepo._constructor() {
    Storage.instance.get(Stores.quantities).then((data) {
      quantities = {};

      if (data != null) {
        try {
          data.forEach((key, value) {
            if (value is Map) {
              quantities[key] = QuantityModel.fromObject(
                QuantityObject.build({'id': key, ...value}),
              );
            }
          });
        } catch (e, stack) {
          print(e);
          print(stack);
        }
      }

      notifyListeners();
    });
  }

  bool get isEmpty => quantities.isEmpty;
  bool get isNotEmpty => quantities.isNotEmpty;
  bool get isNotReady => quantities == null;
  bool get isReady => quantities != null;
  int get length => quantities.length;

  List<QuantityModel> get quantitiesList => quantities.values.toList();

  bool exist(String id) => quantities.containsKey(id);

  QuantityModel getQuantity(String id) => exist(id) ? quantities[id] : null;

  void removeQuantity(String id) {
    quantities.remove(id);

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
    return similarities.sublist(0, end).map((e) => quantities[e.key]).toList();
  }

  void updateQuantity(QuantityModel quantity) {
    if (!exist(quantity.id)) {
      quantities[quantity.id] = quantity;

      Storage.instance.add(
        Stores.quantities,
        quantity.id,
        quantity.toObject().toMap(),
      );
    }

    notifyListeners();
  }
}
