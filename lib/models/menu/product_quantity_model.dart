import 'package:flutter/material.dart';
import 'package:possystem/models/menu/product_ingredient_model.dart';
import 'package:possystem/services/database.dart';

class ProductQuantityModel {
  ProductQuantityModel({
    @required this.quantityId,
    this.amount = 0,
    this.additionalCost = 0,
    this.additionalPrice = 0,
  });

  String quantityId;
  num amount;
  num additionalCost;
  num additionalPrice;

  factory ProductQuantityModel.fromMap(
    String quantityId,
    Map<String, dynamic> data,
  ) {
    return ProductQuantityModel(
      quantityId: quantityId,
      amount: data['amount'],
      additionalCost: data['additionalCost'],
      additionalPrice: data['additionalPrice'],
    );
  }

  factory ProductQuantityModel.empty() {
    return ProductQuantityModel(quantityId: null);
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
    ProductQuantityModel quantity,
  ) {
    final updateData = getUpdateData(ingredient, quantity);

    if (updateData.isEmpty) return;

    Database.service.update(Collections.menu, updateData);
  }

  Map<String, dynamic> getUpdateData(
    ProductIngredientModel ingredient,
    ProductQuantityModel quantity,
  ) {
    final prefix = '${ingredient.prefixQuantities}.$id';
    final updateData = <String, dynamic>{};
    if (quantity.amount != amount) {
      amount = quantity.amount;
      updateData['$prefix.amount'] = amount;
    }
    if (quantity.additionalCost != additionalCost) {
      additionalCost = quantity.additionalCost;
      updateData['$prefix.additionalCost'] = additionalCost;
    }
    if (quantity.additionalPrice != additionalPrice) {
      additionalPrice = quantity.additionalPrice;
      updateData['$prefix.additionalPrice'] = additionalPrice;
    }
    // final
    if (quantity.quantityId != quantityId) {
      updateData['$prefix'] = null;
      quantityId = quantity.quantityId;
      updateData['${ingredient.prefixQuantities}.$id'] = toMap();
    }

    return updateData;
  }

  // GETTER

  bool get isNotReady => quantityId == null;

  String get id => quantityId;
}
