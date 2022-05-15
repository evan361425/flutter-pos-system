import 'dart:math';

import 'package:possystem/models/model.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/repository.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/services/storage.dart';

class Ingredient extends Model<IngredientObject>
    with ModelStorage<IngredientObject>, ModelSearchable<IngredientObject> {
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
  final Stores storageStore = Stores.stock;

  Ingredient({
    String? id,
    ModelStatus? status,
    String name = 'ingredient',
    this.currentAmount,
    this.warningAmount,
    this.alertAmount,
    this.lastAmount,
    this.lastAddAmount,
    this.updatedAt,
  }) : super(id, status) {
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

  factory Ingredient.fromRow(Ingredient? ori, List<String> row) {
    final amount = row.length > 1 ? num.tryParse(row[1]) : null;
    final status = ori == null
        ? ModelStatus.staged
        : (amount == ori.currentAmount
            ? ModelStatus.normal
            : ModelStatus.updated);

    return Ingredient(
      id: ori?.id,
      name: row[0],
      currentAmount: amount,
      status: status,
    );
  }

  @override
  Stock get repository => Stock.instance;

  @override
  set repository(Repository repo) {}

  Future<void> addAmount(num amount) =>
      Stock.instance.applyAmounts({id: amount});

  /// Add/minus [amount] of ingredient and return update data
  Map<String, Object> getUpdateData(num amount, {onlyAmount = false}) {
    final newAmount = (currentAmount ?? 0) + amount;
    final object = amount > 0 && !onlyAmount
        ? IngredientObject(
            lastAddAmount: amount,
            currentAmount: newAmount,
            lastAmount: newAmount,
          )
        : IngredientObject(currentAmount: max(newAmount, 0));

    return object.diff(this);
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
}
