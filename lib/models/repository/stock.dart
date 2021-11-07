import 'package:flutter/material.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/services/storage.dart';

import '../repository.dart';

class Stock extends ChangeNotifier
    with
        Repository<Ingredient>,
        RepositoryStorage<Ingredient>,
        RepositorySearchable<Ingredient> {
  static late Stock instance;

  @override
  final Stores storageStore = Stores.stock;

  Stock() {
    instance = this;
  }

  DateTime? get updatedAt {
    DateTime? lastest;
    for (var element in items) {
      if (lastest == null) {
        lastest = element.updatedAt;
      } else if (element.updatedAt?.isAfter(lastest) == true) {
        lastest = element.updatedAt;
      }
    }

    return lastest;
  }

  Future<void> applyAmounts(
    Map<String, num> amounts, {
    onlyAmount = false,
  }) async {
    final updateData = <String, Object>{};

    amounts.forEach((id, amount) {
      if (amount != 0) {
        getItem(id)
            ?.getUpdateData(amount, onlyAmount: onlyAmount)
            .forEach((key, value) {
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

  /// [oldData] is helpful when reverting order
  Future<void> order(OrderObject data, {OrderObject? oldData}) async {
    final amounts = <String, num>{};

    for (var product in data.products) {
      for (var ingredient in product.ingredients.values) {
        amounts[ingredient.id] =
            (amounts[ingredient.id] ?? 0) - ingredient.amount;
      }
    }

    // if we need to update order, need to revert stock status
    if (oldData != null) {
      for (var product in oldData.products) {
        for (var ingredient in product.ingredients.values) {
          amounts[ingredient.id] =
              (amounts[ingredient.id] ?? 0) + ingredient.amount;
        }
      }
    }

    return applyAmounts(amounts, onlyAmount: true);
  }
}
