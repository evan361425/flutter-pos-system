import 'dart:math';

import 'package:flutter/material.dart';
import 'package:possystem/helper/util.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/repository/stock_model.dart';
import 'package:possystem/services/database.dart';

class IngredientModel extends ChangeNotifier {
  final String id;

  String name;

  num currentAmount;

  num warningAmount;

  num alertAmount;

  num lastAmount;

  num lastAddAmount;

  IngredientModel({
    @required this.name,
    this.currentAmount,
    this.warningAmount,
    this.alertAmount,
    this.lastAmount,
    this.lastAddAmount,
    String id,
  }) : id = id ?? Util.uuidV4();

  factory IngredientModel.fromObject(IngredientObject object) =>
      IngredientModel(
        id: object.id,
        name: object.name,
        currentAmount: object.currentAmount,
        warningAmount: object.warningAmount,
        alertAmount: object.alertAmount,
        lastAmount: object.lastAmount,
        lastAddAmount: object.lastAddAmount,
      );

  String get prefix => 'ingredients.$id';

  void addAmount(num amount) => StockModel.instance.applyAmounts({id: amount});

  int getSimilarity(String searchText) {
    return Util.similarity(name, searchText);
    // print('$name Similarity to $searchText is $_similarityRating');
  }

  IngredientObject toObject() => IngredientObject(
        id: id,
        name: name,
        currentAmount: currentAmount,
        warningAmount: warningAmount,
        alertAmount: alertAmount,
        lastAddAmount: lastAddAmount,
        lastAmount: lastAmount,
      );

  Future<void> update(IngredientObject object) {
    final updateData = object.diff(this);

    if (updateData.isEmpty) return Future.value();

    notifyListeners();

    return Database.instance.update(Collections.stock, updateData);
  }

  Map<String, num> updateInfo(num amount) {
    if (amount > 0) {
      lastAddAmount = amount;
      currentAmount = (currentAmount ?? 0) + amount;
      lastAmount = currentAmount;

      print('$name current: $currentAmount, last: $lastAmount');

      return {
        '$prefix.currentAmount': currentAmount,
        '$prefix.lastAddAmount': lastAddAmount,
        '$prefix.lastAmount': lastAmount,
      };
    } else {
      currentAmount = max((currentAmount ?? 0) + amount, 0);
      print('$name current: $currentAmount');

      return {'$prefix.currentAmount': currentAmount};
    }
  }
}
