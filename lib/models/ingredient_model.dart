import 'package:flutter/material.dart';
import 'package:possystem/helper/util.dart';
import 'package:possystem/services/database.dart';
import 'package:string_similarity/string_similarity.dart';

class IngredientModel extends ChangeNotifier {
  IngredientModel({
    @required this.name,
    this.currentAmount = 0,
    this.warningAmount = 0,
    this.alertAmount = 0,
    this.lastAmount = 0,
    String id,
  }) : id = id ?? Util.uuidV4();

  final String id;
  String name;
  double currentAmount;
  double warningAmount;
  double alertAmount;
  double lastAmount;

  factory IngredientModel.fromMap({
    String id,
    Map<String, dynamic> data,
  }) {
    return IngredientModel(
      name: data['name'],
      currentAmount: data['currentAmount'],
      warningAmount: data['warningAmount'],
      alertAmount: data['alertAmount'],
      lastAmount: data['lastAmount'],
      id: id,
    );
  }

  factory IngredientModel.empty() {
    return IngredientModel(name: null);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'currentAmount': currentAmount,
      'warningAmount': warningAmount,
      'alertAmount': alertAmount,
      'lastAmount': lastAmount,
    };
  }

  // STATE CHANGE

  Future<void> update(IngredientModel newIngredient) async {
    final updateData = {};
    final originData = toMap();
    newIngredient.toMap().forEach((key, value) {
      if (originData[key] != value) {
        updateData['$id.$key'] = value;
      }
    });

    return Database.service
        .update(Collections.ingredient, updateData)
        .then((_) {
      name = newIngredient.name;
      currentAmount = newIngredient.currentAmount;
      warningAmount = newIngredient.warningAmount;
      alertAmount = newIngredient.alertAmount;
      lastAmount = newIngredient.lastAmount;
      notifyListeners();
    });
  }

  // SETTER

  double _similarityRating;
  void setSimilarity(String searchText) {
    _similarityRating = searchText.similarityTo(name);
  }

  double get similarity => _similarityRating;

  // GETTER

  bool get isReady => name != null;
  bool get isNotReady => name == null;
}
