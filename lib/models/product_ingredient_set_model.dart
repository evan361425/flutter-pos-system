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

  String ingredientSetId;
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

  void update(
    ProductIngredientModel ingredient,
    ProductIngredientSetModel newSet,
  ) {
    final updateData = getUpdateData(ingredient, newSet);

    if (updateData.isEmpty) return;

    Database.service.update(Collections.menu, updateData);
  }

  Map<String, dynamic> getUpdateData(
    ProductIngredientModel ingredient,
    ProductIngredientSetModel newSet,
  ) {
    final prefix = '${ingredient.prefix}.additionalSets.$id';
    final updateData = <String, dynamic>{};
    if (newSet.amount != amount) {
      amount = newSet.amount;
      updateData['$prefix.amount'] = amount;
    }
    if (newSet.additionalCost != additionalCost) {
      additionalCost = newSet.additionalCost;
      updateData['$prefix.additionalCost'] = additionalCost;
    }
    if (newSet.additionalPrice != additionalPrice) {
      additionalPrice = newSet.additionalPrice;
      updateData['$prefix.additionalPrice'] = additionalPrice;
    }
    // final
    if (newSet.ingredientSetId != ingredientSetId) {
      updateData['$prefix'] = null;
      ingredientSetId = newSet.ingredientSetId;
      updateData['${ingredient.prefix}.additionalSets.$id'] = toMap();
    }

    return updateData;
  }

  // GETTER

  bool get isNotReady => ingredientSetId == null;

  String get id => ingredientSetId;
}
