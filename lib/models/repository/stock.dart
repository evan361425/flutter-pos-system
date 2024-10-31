import 'package:flutter/material.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/services/storage.dart';

import '../repository.dart';

class Stock extends ChangeNotifier
    with Repository<Ingredient>, RepositoryStorage<Ingredient>, RepositorySearchable<Ingredient> {
  static late Stock instance;

  @override
  final Stores storageStore = Stores.stock;

  Stock() {
    instance = this;
  }

  Future<void> applyAmounts(
    Map<String, num> amounts, {
    onlyAmount = false,
  }) async {
    final updateData = <String, Object?>{};

    amounts.forEach((id, amount) {
      if (amount != 0) {
        getItem(id)?.getUpdateData(amount, onlyAmount: onlyAmount).forEach((key, value) {
          updateData[key] = value;
        });
      }
    });

    if (updateData.isEmpty) return Future.value();

    // should use [saveBatch] instead
    await Storage.instance.set(Stores.stock, updateData);

    notifyListeners();
  }

  @override
  Ingredient buildItem(String id, Map<String, Object?> value) {
    return Ingredient.fromObject(
      IngredientObject.build({
        'id': id,
        ...value,
      }),
    );
  }

  /// Update amounts by order.
  Future<void> order(OrderObject data) async {
    final amounts = <String, num>{};

    data.applyToStock(amounts, add: false);

    return applyAmounts(amounts, onlyAmount: true);
  }

  @override
  Future<void> commitStaged({bool save = true, bool reset = true}) {
    // Avoid reset since it will effect Menu and Replenishment
    return super.commitStaged(save: save, reset: false);
  }
}
