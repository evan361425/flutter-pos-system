import 'package:flutter/material.dart';
import 'package:possystem/models/product_ingredient_set_model.dart';
import 'package:possystem/services/database.dart';

import 'product_model.dart';

class ProductIngredientModel {
  ProductIngredientModel({
    @required this.ingredientId,
    @required this.product,
    this.defaultAmount = 0,
    Map<String, ProductIngredientSetModel> ingredientSets,
  }) : ingredientSets = ingredientSets ?? {};

  final String ingredientId;
  final ProductModel product;
  final Map<String, ProductIngredientSetModel> ingredientSets;
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

  Future<void> add(ProductIngredientSetModel newSet) async {
    await Database.service.update(Collections.menu, {
      '$prefix.additionalSets.${newSet.id}': newSet.toMap(),
    });

    ingredientSets[newSet.id] = newSet;
    product.ingredientChanged();
  }

  Future<void> update({
    num defaultAmount,
  }) async {
    if (defaultAmount == this.defaultAmount) return;

    final updateData = {'$prefix.defaultAmount': defaultAmount};

    return Database.service.update(Collections.menu, updateData).then((_) {
      this.defaultAmount = defaultAmount;
      product.ingredientChanged();
    });
  }

  // GETTER

  bool get isReady => ingredientId != null;
  bool get isNotReady => ingredientId == null;
  String get prefix => '${product.prefix}.ingredients.$id';
  String get id => ingredientId;
}
