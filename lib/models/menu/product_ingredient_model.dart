import 'package:flutter/material.dart';
import 'package:possystem/models/menu/product_ingredient_set_model.dart';
import 'package:possystem/services/database.dart';

import 'product_model.dart';

class ProductIngredientModel {
  ProductIngredientModel({
    @required this.ingredientId,
    @required this.product,
    this.defaultAmount = 0,
    Map<String, ProductIngredientSetModel> ingredientSets,
  }) : ingredientSets = ingredientSets ?? {};

  final ProductModel product;
  final Map<String, ProductIngredientSetModel> ingredientSets;
  String ingredientId;
  num defaultAmount;

  factory ProductIngredientModel.fromMap({
    ProductModel product,
    Map<String, dynamic> data,
    String ingredientId,
  }) {
    final ingredientSetsMap = data['additionalSets'];
    final ingredientSets = <String, ProductIngredientSetModel>{};

    if (ingredientSetsMap is Map<String, Map>) {
      ingredientSetsMap.forEach((ingredientSetId, ingredientSet) {
        if (ingredientSet is Map) {
          ingredientSets[ingredientSetId] = ProductIngredientSetModel.fromMap(
            ingredientSetId,
            ingredientSet,
          );
        }
      });
    }

    return ProductIngredientModel(
      product: product,
      ingredientId: ingredientId,
      defaultAmount: data['defaultAmount'],
      ingredientSets: ingredientSets,
    );
  }

  factory ProductIngredientModel.empty(ProductModel product) {
    return ProductIngredientModel(product: product, ingredientId: null);
  }

  Map<String, dynamic> toMap() {
    return {
      'defaultAmount': defaultAmount,
      'additionalSets': {
        for (var entry in ingredientSets.entries) entry.key: entry.value.toMap()
      },
    };
  }

  // STATE CHANGE

  void addIngredientSet(ProductIngredientSetModel newSet) {
    Database.service.update(Collections.menu, {
      '$prefix.additionalSets.${newSet.id}': newSet.toMap(),
    });

    ingredientSets[newSet.id] = newSet;
    product.ingredientChanged();
  }

  void update({
    num defaultAmount,
    String ingredientId,
  }) {
    final updateData = {};
    if (defaultAmount != this.defaultAmount) {
      this.defaultAmount = defaultAmount;
      updateData['$prefix.$id.defaultAmount'] = defaultAmount;
    }
    // after all property set
    if (ingredientId != this.ingredientId) {
      // delete old value
      updateData['$prefix.$id'] = null;
      this.ingredientId = ingredientId;
      updateData['$prefix.$ingredientId'] = toMap();
    }

    if (updateData.isEmpty) return;

    Database.service.update(Collections.menu, updateData);
  }

  bool has(String id) {
    return ingredientSets.containsKey(id);
  }

  // GETTER

  bool get isReady => ingredientId != null;
  bool get isNotReady => ingredientId == null;
  String get prefix => '${product.prefix}.ingredients';
  String get id => ingredientId;
}
