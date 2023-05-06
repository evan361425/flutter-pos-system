import 'dart:math';

import 'package:possystem/models/model.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/repository.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/services/storage.dart';

class Ingredient extends Model<IngredientObject>
    with ModelStorage<IngredientObject>, ModelSearchable<IngredientObject> {
  /// current amount in stock
  num currentAmount;

  /// total amount in stock
  num? totalAmount;

  /// warning threshold
  num? warningAmount;

  /// alert threshold
  num? alertAmount;

  /// amount after last replenishment
  num? lastAmount;

  DateTime? updatedAt;

  @override
  final Stores storageStore = Stores.stock;

  Ingredient({
    String? id,
    ModelStatus? status,
    String name = 'ingredient',
    this.currentAmount = 0.0,
    this.totalAmount,
    this.warningAmount,
    this.alertAmount,
    this.lastAmount,
    this.updatedAt,
  }) : super(id, status) {
    this.name = name;
  }

  factory Ingredient.fromObject(IngredientObject object) => Ingredient(
        id: object.id,
        name: object.name ?? '',
        currentAmount: object.currentAmount ?? 0,
        warningAmount: object.warningAmount,
        alertAmount: object.alertAmount,
        lastAmount: object.lastAmount,
        totalAmount: object.totalAmount,
        updatedAt: object.updatedAt,
      );

  factory Ingredient.fromRow(Ingredient? ori, List<String> row) {
    final amount = (row.length > 1 ? double.tryParse(row[1]) : null) ?? 0;
    final total = row.length > 2 ? double.tryParse(row[2]) : null;
    final status = ori == null
        ? ModelStatus.staged
        : (amount == ori.currentAmount && total == ori.totalAmount
            ? ModelStatus.normal
            : ModelStatus.updated);

    return Ingredient(
      id: ori?.id,
      name: row[0],
      currentAmount: amount,
      totalAmount: total,
      status: status,
    );
  }

  double get maxAmount =>
      (totalAmount ?? lastAmount ?? currentAmount).toDouble();

  @override
  Stock get repository => Stock.instance;

  @override
  set repository(Repository repo) {}

  Future<void> setAmount(num amount) =>
      // only allow difference
      Stock.instance.applyAmounts({id: amount - currentAmount});

  /// Add/minus [amount] of ingredient and return update data
  Map<String, Object?> getUpdateData(num amount, {onlyAmount = false}) {
    final newAmount = currentAmount + amount;
    final object = amount > 0 && !onlyAmount
        ? IngredientObject(
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
        totalAmount: totalAmount,
        lastAmount: lastAmount,
        updatedAt: updatedAt,
      );
}
