import 'dart:math';

import 'package:flutter/material.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/repository/stock_model.dart';
import 'package:possystem/services/storage.dart';

class IngredientModel extends ChangeNotifier {
  final String id;

  // ingredient name: cheese, bread, ...
  String name;

  // current amount in stock
  num? currentAmount;

  // warning threshold
  num? warningAmount;

  // alert threshold
  num? alertAmount;

  // amount after last replenishment
  num? lastAmount;

  // value of last added
  num? lastAddAmount;

  DateTime? updatedAt;

  IngredientModel({
    required this.name,
    this.currentAmount,
    this.warningAmount,
    this.alertAmount,
    this.lastAmount,
    this.lastAddAmount,
    this.updatedAt,
    String? id,
  }) : id = id ?? Util.uuidV4();

  factory IngredientModel.fromObject(IngredientObject object) =>
      IngredientModel(
        id: object.id,
        name: object.name ?? '',
        currentAmount: object.currentAmount,
        warningAmount: object.warningAmount,
        alertAmount: object.alertAmount,
        lastAmount: object.lastAmount,
        lastAddAmount: object.lastAddAmount,
        updatedAt: object.updatedAt,
      );

  String get prefix => id;

  Future<void> addAmount(num amount) =>
      StockModel.instance.applyAmounts({id: amount});

  int getSimilarity(String searchText) => Util.similarity(name, searchText);

  Future<void> remove() async {
    info(toString(), 'stock.ingredient.remove');
    await Storage.instance.set(Stores.stock, {prefix: null});

    StockModel.instance.removeIngredient(id);
  }

  IngredientObject toObject() => IngredientObject(
        id: id,
        name: name,
        currentAmount: currentAmount,
        warningAmount: warningAmount,
        alertAmount: alertAmount,
        lastAddAmount: lastAddAmount,
        lastAmount: lastAmount,
        updatedAt: updatedAt,
      );

  @override
  String toString() => name;

  Future<void> update(IngredientObject object) {
    final updateData = object.diff(this);

    if (updateData.isEmpty) return Future.value();

    info(toString(), 'stock.ingredient.update');
    notifyListeners();

    return Storage.instance.set(Stores.stock, updateData);
  }

  Map<String, Object> updateInfo(num amount) {
    final object = amount > 0
        ? IngredientObject(
            lastAddAmount: amount,
            currentAmount: (currentAmount ?? 0) + amount,
            lastAmount: (currentAmount ?? 0) + amount,
          )
        : IngredientObject(
            currentAmount: max((currentAmount ?? 0) + amount, 0),
          );

    return object.diff(this);
  }
}
