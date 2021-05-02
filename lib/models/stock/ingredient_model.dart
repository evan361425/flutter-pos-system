import 'dart:math';

import 'package:flutter/material.dart';
import 'package:possystem/helper/util.dart';
import 'package:possystem/models/repository/stock_model.dart';
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
  num currentAmount;
  num warningAmount;
  num alertAmount;
  num lastAmount;
  num lastAddAmount;

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
    num amount,
  }) {
    final updateData = <String, dynamic>{};
    if (name != null && name != this.name) {
      this.name = name;
      updateData['$ColumnIngredient$id.name'] = name;
    }
    if (amount != null && amount != currentAmount) {
      currentAmount = amount;
      updateData['$ColumnIngredient.$id.currentAmount'] = amount;
    }

    if (updateData.isNotEmpty) {
      Database.instance.update(Collections.stock, updateData);

      notifyListeners();
    }
  }

  void addAmount(num amount) {
    StockModel.instance.applyIngredients({id: amount});
  }

  Map<String, dynamic> addAmountUpdateData(num amount) {
    if (amount > 0) {
      lastAddAmount = amount;
      currentAmount = (currentAmount ?? 0) + amount;
      lastAmount = currentAmount;
    } else {
      currentAmount = max((currentAmount ?? 0) + amount, 0);
    }

    print('$name current: $currentAmount, last: $lastAmount');

    return {
      '$ColumnIngredient.$id.currentAmount': currentAmount,
      '$ColumnIngredient.$id.lastAddAmount': lastAddAmount,
      '$ColumnIngredient.$id.lastAmount': lastAmount,
    };
  }

  int _similarityRating;
  void setSimilarity(String searchText) {
    _similarityRating = Util.similarity(name, searchText);
    // print('$name Similarity to $searchText is $_similarityRating');
  }

  int get similarity => _similarityRating;
}
