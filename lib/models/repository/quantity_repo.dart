import 'dart:math';

import 'package:flutter/material.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/repository.dart';
import 'package:possystem/models/stock/quantity_model.dart';
import 'package:possystem/services/storage.dart';

class QuantityRepo extends ChangeNotifier
    with Repository<QuantityModel>, InitilizableRepository {
  static late QuantityRepo instance;

  QuantityRepo() {
    initialize();

    QuantityRepo.instance = this;
  }

  @override
  String get childCode => 'quantities.quantity';

  @override
  Stores get storageStore => Stores.quantities;

  @override
  QuantityModel buildModel(String id, Map<String, Object> value) {
    return QuantityModel.fromObject(
      QuantityObject.build({
        'id': id,
        ...value,
      }),
    );
  }

  List<QuantityModel> sortBySimilarity(String text) {
    if (text.isEmpty) {
      return [];
    }

    final similarities = childMap.entries
        .map((e) => MapEntry(e.key, e.value.getSimilarity(text)))
        .where((e) => e.value > 0)
        .toList();
    similarities.sort((ing1, ing2) {
      // if ing1 < ing2 return -1 will make ing1 be the first one
      if (ing1.value == ing2.value) return 0;
      return ing1.value < ing2.value ? 1 : -1;
    });

    final end = min(10, similarities.length);
    return similarities.sublist(0, end).map((e) => getChild(e.key)!).toList();
  }
}
