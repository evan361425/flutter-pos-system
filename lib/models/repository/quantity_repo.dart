import 'dart:math';

import 'package:flutter/material.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/stock/quantity_model.dart';
import 'package:possystem/services/storage.dart';

class QuantityRepo extends ChangeNotifier {
  static late QuantityRepo instance;

  late Map<String, QuantityModel> quantities;

  bool isReady = false;

  QuantityRepo() {
    Storage.instance.get(Stores.quantities).then((data) {
      quantities = {};
      isReady = true;

      data.forEach((key, value) {
        try {
          quantities[key] = QuantityModel.fromObject(
            QuantityObject.build({
              'id': key,
              ...value as Map<String, Object>,
            }),
          );
        } catch (e) {
          error(e.toString(), 'quantities.parse.error');
        }
      });

      notifyListeners();
    }).onError((e, stack) {
      error(e.toString(), 'quantities.fetch.error');
      throw Exception('unable to fetch quantities');
    });
    QuantityRepo.instance = this;
  }

  bool get isEmpty => quantities.isEmpty;
  bool get isNotEmpty => quantities.isNotEmpty;
  int get length => quantities.length;

  List<QuantityModel> get quantityList => quantities.values.toList();

  bool exist(String id) => quantities.containsKey(id);

  QuantityModel? getQuantity(String id) => quantities[id];

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
    return similarities
        .sublist(0, end)
        .map((e) => getQuantity(e.key)!)
        .toList();
  }

  Future<void> setQuantity(QuantityModel quantity) async {
    if (!exist(quantity.id)) {
      quantities[quantity.id] = quantity;

      await Storage.instance.add(
        Stores.quantities,
        quantity.id,
        quantity.toObject().toMap(),
      );
    }

    notifyListeners();
  }
}
