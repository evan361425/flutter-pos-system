import 'dart:math';

import 'package:possystem/models/model.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/repository/stock_model.dart';
import 'package:possystem/services/storage.dart';

class IngredientModel extends NotifyModel<IngredientObject>
    with SearchableModel {
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
    required String name,
    this.currentAmount,
    this.warningAmount,
    this.alertAmount,
    this.lastAmount,
    this.lastAddAmount,
    this.updatedAt,
    String? id,
  }) : super(id) {
    this.name = name;
  }

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

  @override
  String get code => 'stock.ingredient';

  @override
  Stores get storageStore => Stores.stock;

  Future<void> addAmount(num amount) =>
      StockModel.instance.applyAmounts({id: amount});

  @override
  void removeFromRepo() {
    StockModel.instance.removeChild(id);
  }

  @override
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
