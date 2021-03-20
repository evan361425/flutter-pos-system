import 'package:flutter/material.dart';
import 'package:possystem/models/product_ingredient_model.dart';
import 'package:possystem/services/database.dart';

class ProductIngredientSetModel {
  ProductIngredientSetModel({
    @required this.ingredientSetId,
    this.amount = 0,
    this.additionalCost = 0,
    this.additionalPrice = 0,
  });

  final String ingredientSetId;
  num amount;
  num additionalCost;
  num additionalPrice;

  factory ProductIngredientSetModel.fromMap(
    String ingredientSetId,
    Map<String, dynamic> data,
  ) {
    return ProductIngredientSetModel(
      ingredientSetId: ingredientSetId,
      amount: data['amount'],
      additionalCost: data['additionalCost'],
      additionalPrice: data['additionalPrice'],
    );
  }

  factory ProductIngredientSetModel.empty() {
    return ProductIngredientSetModel(ingredientSetId: null);
  }

  Map<String, num> toMap() {
    return {
      'amount': amount,
      'additionalCost': additionalCost,
      'additionalPrice': additionalPrice,
    };
  }

  // STATE CHANGE

  Future<void> update(
    ProductIngredientModel ingredient,
    ProductIngredientSetModel newSet,
  ) async {
    final prefix = '${ingredient.prefix}.additionalSets.$id';
    final updateData = {};
    final originData = toMap();
    newSet.toMap().forEach((key, value) {
      if (originData[key] != value) {
        updateData['$prefix.$key'] = value;
      }
    });

    if (updateData.isEmpty) return;

    return Database.service.update(Collections.menu, updateData).then((_) {
      amount = newSet.amount;
      additionalCost = newSet.additionalCost;
      additionalPrice = newSet.additionalPrice;
    });
  }

  // GETTER

  bool get isNotReady => ingredientSetId == null;

  String get id => ingredientSetId;
}
