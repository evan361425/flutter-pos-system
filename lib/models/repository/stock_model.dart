import 'dart:math';

import 'package:flutter/material.dart';
import 'package:possystem/helper/util.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/stock/ingredient_model.dart';
import 'package:possystem/services/database.dart';
import 'package:sprintf/sprintf.dart';

class StockModel extends ChangeNotifier {
  static final StockModel _instance = StockModel._constructor();

  static StockModel get instance => _instance;

  Map<String, IngredientModel> ingredients;

  DateTime updatedTime;

  StockModel._constructor() {
    Database.instance.get(Collections.stock).then((snapsnot) {
      ingredients = {};

      final data = snapsnot.data();
      if (data == null) return;

      try {
        final stock = StockObject.build(data);
        updatedTime = stock.updatedTime;
        stock.ingredients.forEach((ingredient) {
          ingredients[ingredient.id] = IngredientModel.fromObject(ingredient);
        });
      } catch (e) {
        print(e);
      }

      notifyListeners();
    });
  }

  List<IngredientModel> get ingredientList => ingredients.values.toList();

  bool get isEmpty => ingredients.isEmpty;

  bool get isNotReady => ingredients == null;

  bool get isReady => ingredients != null;

  String get updatedDate => Util.timeToDate(updatedTime);

  IngredientModel operator [](String id) =>
      ingredients[id] ?? ingredients.values.first;

  Future<void> applyAmounts(Map<String, num> amounts) {
    final updateData = <String, dynamic>{};

    amounts.forEach((ingredientId, amount) {
      updateData.addAll(ingredients[ingredientId].updateInfo(amount));
    });

    if (updateData.isEmpty) return Future.value();

    updatedTime = DateTime.now();
    updateData['updatedTime'] = updatedTime.toString();

    notifyListeners();

    return Database.instance.update(Collections.stock, updateData);
  }

  bool hasContain(String id) => ingredients.containsKey(id);

  Future<void> order(OrderObject data) {
    final amounts = <String, num>{};

    data.products.forEach((product) {
      product.ingredients.forEach((id, ingredient) {
        if (amounts.containsKey(id)) {
          amounts[id] -= ingredient.amount;
        } else {
          amounts[id] = -ingredient.amount;
        }
      });
    });

    return applyAmounts(amounts);
  }

  Future<void> removeIngredient(IngredientModel ingredient) {
    ingredients.remove(ingredient.id);

    notifyListeners();

    return Database.instance.update(Collections.stock, {
      ingredient.prefix: null,
    });
  }

  void updateIngredient(IngredientModel ingredient) {
    if (!hasContain(ingredient.id)) {
      ingredients[ingredient.id] = ingredient;

      final updateData = {ingredient.prefix: ingredient.toObject().toMap()};

      Database.instance.set(Collections.stock, updateData);
    }

    notifyListeners();
  }

  List<IngredientModel> sortBySimilarity(String text) {
    if (text.isEmpty) {
      return [];
    }

    final similarities = ingredients.entries
        .map((e) => MapEntry(e.key, e.value.getSimilarity(text)))
        .where((e) => e.value > 0)
        .toList();
    similarities.sort((ing1, ing2) {
      // if ing1 < ing2 return -1 will make ing1 be the first one
      if (ing1.value == ing2.value) return 0;
      return ing1.value < ing2.value ? 1 : -1;
    });

    final end = min(10, similarities.length);
    return similarities.sublist(0, end).map((e) => ingredients[e.key]);
  }
}
