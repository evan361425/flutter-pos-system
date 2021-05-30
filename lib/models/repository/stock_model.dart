import 'dart:math';

import 'package:flutter/material.dart';
import 'package:possystem/helper/util.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/stock/ingredient_model.dart';
import 'package:possystem/services/storage.dart';

class StockModel extends ChangeNotifier {
  static late StockModel instance;

  Map<String, IngredientModel>? ingredients;

  StockModel() {
    Storage.instance.get(Stores.stock).then((data) {
      ingredients = {};

      try {
        data.forEach((key, value) {
          if (value is Map) {
            ingredients![key] = IngredientModel.fromObject(
              IngredientObject.build({
                'id': key,
                ...value as Map<String, Object?>,
              }),
            );
          }
        });
      } catch (e, stack) {
        print(e);
        print(stack);
      }

      notifyListeners();
    });
    StockModel.instance = this;
  }

  List<IngredientModel> get ingredientList => ingredients!.values.toList();

  bool get isEmpty => ingredients!.isEmpty;
  bool get isNotEmpty => ingredients!.isNotEmpty;
  bool get isNotReady => ingredients == null;
  bool get isReady => ingredients != null;
  int get length => ingredients!.length;

  String? get updatedDate {
    if (isEmpty) return null;

    DateTime? lastest;
    ingredients!.values.forEach((element) {
      if (lastest == null) {
        lastest = element.updatedAt;
      } else if (element.updatedAt?.isAfter(lastest!) == true) {
        lastest = element.updatedAt;
      }
    });

    return Util.timeToDate(lastest);
  }

  Future<void> applyAmounts(Map<String, num> amounts) {
    final updateData = <String, Object?>{};

    amounts.forEach((id, amount) {
      if (amount != 0) {
        updateData.addAll(getIngredient(id)?.updateInfo(amount) ?? {});
      }
    });

    if (updateData.isEmpty) return Future.value();

    notifyListeners();

    return Storage.instance.set(Stores.stock, updateData);
  }

  bool exist(String id) => ingredients![id] != null;

  IngredientModel? getIngredient(String id) => ingredients![id];

  /// [oldData] is helpful when reverting order
  Future<void> order(OrderObject data, {OrderObject? oldData}) {
    final amounts = <String, num>{};

    data.products.forEach((product) {
      product.ingredients.forEach((id, ingredient) {
        amounts[id] = (amounts[id] ?? 0) - ingredient.amount;
      });
    });

    // if we need to update order, need to revert stock status
    oldData?.products.forEach((product) {
      product.ingredients.forEach((id, ingredient) {
        amounts[id] = (amounts[id] ?? 0) + ingredient.amount;
      });
    });

    return applyAmounts(amounts);
  }

  void removeIngredient(String id) {
    ingredients!.remove(id);

    notifyListeners();
  }

  List<IngredientModel> sortBySimilarity(String text) {
    if (text.isEmpty) {
      return [];
    }

    final similarities = ingredients!.entries
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
        .map((e) => getIngredient(e.key)!)
        .toList();
  }

  void updateIngredient(IngredientModel ingredient) {
    if (!exist(ingredient.id)) {
      ingredients![ingredient.id] = ingredient;

      Storage.instance.add(
        Stores.stock,
        ingredient.id,
        ingredient.toObject().toMap(),
      );
    }

    notifyListeners();
  }
}
