import 'package:flutter/material.dart';
import 'package:possystem/helper/util.dart';
import 'package:possystem/services/database.dart';

class IngredientModel extends ChangeNotifier {
  IngredientModel({
    @required this.name,
    this.currentAmount,
    this.warningAmount,
    this.alertAmount,
    this.lastAmount,
    this.lastAddAmount,
    String id,
  }) : id = id ?? Util.uuidV4();

  final String id;
  String name;
  double currentAmount;
  double warningAmount;
  double alertAmount;
  double lastAmount;
  double lastAddAmount;

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
      lastAddAmount: data['lastAddAmount'],
      id: id,
    );
  }

  Map<String, dynamic> toMap() {
    final nonNullProperties = {
      'name': name,
      'currentAmount': currentAmount,
      'warningAmount': warningAmount,
      'alertAmount': alertAmount,
      'lastAmount': lastAmount,
      'lastAddAmount': lastAddAmount,
    }.entries.where((element) => element != null).toList();

    return {for (var p in nonNullProperties) p.key: p.value};
  }

  // STATE CHANGE

  void update({
    String name,
    double amount,
  }) {
    final updateData = <String, dynamic>{};
    if (name != null && name != this.name) {
      this.name = name;
      updateData['$id.name'] = name;
    }
    if (amount != null && amount != currentAmount) {
      currentAmount = amount;
      updateData['$id.currentAmount'] = amount;
    }

    if (updateData.isNotEmpty) {
      Database.service.update(Collections.ingredient, updateData);

      notifyListeners();
    }
  }

  void addAmount(num amount) {
    if (amount > 0) {
      lastAddAmount = amount;
      lastAmount = currentAmount ?? amount;
    }
    currentAmount = currentAmount == null ? amount : currentAmount + amount;

    Database.service.update(Collections.ingredient, {
      '$id.currentAmount': currentAmount,
      '$id.lastAddAmount': lastAddAmount,
      '$id.lastAmount': lastAmount,
    });
  }

  int _similarityRating;
  void setSimilarity(String searchText) {
    _similarityRating = Util.similarity(name, searchText);
    // print('$name Similarity to $searchText is $_similarityRating');
  }

  int get similarity => _similarityRating;
}
