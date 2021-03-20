import 'package:flutter/material.dart';
import 'package:possystem/models/ingredient_set_model.dart';
import 'package:possystem/services/database.dart';

class IngredientSetIndexModel extends ChangeNotifier {
  IngredientSetIndexModel() {
    loadFromDb();
  }

  Map<String, IngredientSetModel> ingredientSets;

  // I/O
  Future<void> loadFromDb() async {
    var snapshot = await Database.service.get(Collections.ingredient_sets);
    buildFromMap(snapshot.data());
  }

  void buildFromMap(Map<String, dynamic> data) {
    ingredientSets = {};
    if (data == null) return;

    try {
      data.forEach((key, value) {
        if (value is Map) {
          ingredientSets[key] =
              IngredientSetModel.fromMap(id: key, data: value);
        }
      });
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  IngredientSetModel operator [](String id) {
    return ingredientSets[id];
  }

  bool get isReady => ingredientSets != null;
  bool get isNotReady => ingredientSets == null;
  bool get isEmpty => ingredientSets.isEmpty;
}
