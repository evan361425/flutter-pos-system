import 'dart:math';

import 'package:possystem/models/model.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/services/storage.dart';

class Ingredient extends NotifyModel<IngredientObject> with SearchableModel {
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

  @override
  final String logCode = 'stock.ingredient';

  @override
  final Stores storageStore = Stores.stock;

  Ingredient({
    String name = 'ingredient',
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

  factory Ingredient.fromObject(IngredientObject object) => Ingredient(
        id: object.id,
        name: object.name ?? '',
        currentAmount: object.currentAmount,
        warningAmount: object.warningAmount,
        alertAmount: object.alertAmount,
        lastAmount: object.lastAmount,
        lastAddAmount: object.lastAddAmount,
        updatedAt: object.updatedAt,
      );

  Future<void> addAmount(num amount) =>
      Stock.instance.applyAmounts({id: amount});

  /// Add/minus [amount] of ingredient and return update data
  Map<String, Object> getUpdateData(num amount) {
    final object = amount > 0
        ? IngredientObject(
            lastAddAmount: amount,
            currentAmount: (currentAmount ?? 0) + amount,
            lastAmount: (currentAmount ?? 0) + amount,
          )
        : currentAmount == null
            ? IngredientObject()
            : IngredientObject(
                currentAmount: max((currentAmount ?? 0) + amount, 0),
              );

    return object.diff(this);
  }

  @override
  void removeFromRepo() {
    Stock.instance.removeItem(id);
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
}
