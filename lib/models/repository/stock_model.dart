import 'package:flutter/material.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/stock/ingredient_model.dart';
import 'package:possystem/services/database.dart';
import 'package:sprintf/sprintf.dart';

class StockModel extends ChangeNotifier {
  static final StockModel _instance = StockModel._constructor();

  static StockModel get instance => _instance;

  StockModel._constructor() {
    Database.instance.get(Collections.stock).then((snapsnot) {
      final data = snapsnot.data();
      buildFromMap(data);
      notifyListeners();
    });
  }

  Map<String, IngredientModel> ingredients;
  DateTime updatedTime;

  void buildFromMap(Map<String, dynamic> data) {
    ingredients = {};
    if (data == null) return;

    try {
      updatedTime = DateTime.parse(data[ColumnUpdatedTime]);
    } catch (e) {
      updatedTime = null;
    }

    try {
      data[ColumnIngredient].forEach((key, value) {
        if (value is Map) {
          ingredients[key] = IngredientModel.fromMap(id: key, data: value);
        }
      });
    } catch (e) {
      print(e);
    }
  }

  void order(OrderObject data) {
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

    applyIngredients(amounts);
  }

  void updateIngredient(IngredientModel ingredient) {
    if (!hasContain(ingredient.id)) {
      ingredients[ingredient.id] = ingredient;

      final updateData = {
        '$ColumnIngredient.${ingredient.id}': ingredient.toMap(),
      };
      Database.instance.set(Collections.stock, updateData);
      notifyListeners();
    }
  }

  void removeIngredient(String id) {
    ingredients.remove(id);
    Database.instance.update(Collections.stock, {
      '$ColumnIngredient$id': null,
    });
    notifyListeners();
  }

  void applyIngredients(Map<String, num> amounts) {
    final updateData = <String, dynamic>{};
    amounts.forEach((ingredientId, amount) {
      updateData.addAll(
        ingredients[ingredientId].addAmountUpdateData(amount),
      );
    });

    updatedTime = DateTime.now();
    updateData[ColumnUpdatedTime] = updatedTime.toString();

    notifyListeners();
  }

  // TOOLS

  bool hasContain(String id) => ingredients.containsKey(id);
  IngredientModel operator [](String id) => ingredients[id];

  // GETTER

  List<IngredientModel> get ingredientList => ingredients.values.toList();
  bool get isReady => ingredients != null;
  bool get isNotReady => ingredients == null;
  bool get isEmpty => ingredients.isEmpty;
  String get updatedDate => updatedTime == null
      ? null
      : sprintf('%04d-%02d-%02d', [
          updatedTime.year,
          updatedTime.month,
          updatedTime.day,
        ]);
}

const ColumnUpdatedTime = 'updatedTime';
const ColumnIngredient = 'ingredients';
