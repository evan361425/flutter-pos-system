import 'package:flutter/material.dart';
import 'package:possystem/models/ingredient_model.dart';
import 'package:possystem/services/database.dart';

class StockModel extends ChangeNotifier {
  StockModel() {
    loadFromDb();
  }

  Map<String, IngredientModel> ingredients;

  // I/O
  Future<void> loadFromDb() async {
    var snapshot = await Database.service.get(Collections.ingredient);
    buildFromMap(snapshot.data());
  }

  void buildFromMap(Map<String, dynamic> data) {
    ingredients = {};
    if (data == null) return;

    try {
      data.forEach((key, value) {
        if (value is Map) {
          ingredients[key] = IngredientModel.fromMap(id: key, data: value);
        }
      });
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  IngredientModel addIngredient(String name) {
    final ingredient = IngredientModel(name: name);
    ingredients[ingredient.id] = ingredient;

    final updateData = {'${ingredient.id}': ingredient};
    Database.service.set(Collections.ingredient, updateData);

    return ingredient;
  }

  IngredientModel operator [](String id) {
    return ingredients[id];
  }

  bool get isReady => ingredients != null;
  bool get isEmpty => ingredients.isEmpty;
}
