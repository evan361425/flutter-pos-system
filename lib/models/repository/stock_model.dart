import 'package:flutter/material.dart';
import 'package:possystem/models/stock/ingredient_model.dart';
import 'package:possystem/services/database.dart';
import 'package:sprintf/sprintf.dart';

class StockModel extends ChangeNotifier {
  StockModel() {
    loadFromDb();
  }

  Map<String, IngredientModel> ingredients;
  DateTime updatedTime;

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

  void addIngredient(IngredientModel ingredient) {
    ingredients[ingredient.id] = ingredient;

    final updateData = {'${ingredient.id}': ingredient.toMap()};
    Database.service.set(Collections.ingredient, updateData);
  }

  void removeIngredient(String id) {
    ingredients.remove(id);
    Database.service.update(Collections.ingredient, {id: null});
    notifyListeners();
  }

  void changedIngredient() {
    updatedTime = DateTime.now();
    // notifyListeners();
  }

  // TOOLS

  bool hasContain(String id) {
    return ingredients.containsKey(id);
  }

  // GETTER

  IngredientModel operator [](String id) {
    return ingredients[id];
  }

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
