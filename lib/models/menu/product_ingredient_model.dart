import 'package:flutter/material.dart';
import 'package:possystem/models/menu/product_quantity_model.dart';
import 'package:possystem/services/database.dart';

import 'product_model.dart';

class ProductIngredientModel {
  ProductIngredientModel({
    @required this.ingredientId,
    @required this.product,
    this.defaultAmount = 0,
    Map<String, ProductQuantityModel> quantities,
  }) : quantities = quantities ?? {};

  final ProductModel product;
  final Map<String, ProductQuantityModel> quantities;
  String ingredientId;
  num defaultAmount;

  factory ProductIngredientModel.fromMap({
    ProductModel product,
    Map<String, dynamic> data,
    String ingredientId,
  }) {
    final quantitiesMap = data['quantities'];
    final quantities = <String, ProductQuantityModel>{};

    if (quantitiesMap is Map<String, Map>) {
      quantitiesMap.forEach((quantityId, quantity) {
        if (quantity is Map) {
          quantities[quantityId] = ProductQuantityModel.fromMap(
            quantityId,
            quantity,
          );
        }
      });
    }

    return ProductIngredientModel(
      product: product,
      ingredientId: ingredientId,
      defaultAmount: data['defaultAmount'],
      quantities: quantities,
    );
  }

  factory ProductIngredientModel.empty(ProductModel product) {
    return ProductIngredientModel(product: product, ingredientId: null);
  }

  Map<String, dynamic> toMap() {
    return {
      'defaultAmount': defaultAmount,
      'quantities': {
        for (var entry in quantities.entries) entry.key: entry.value.toMap()
      },
    };
  }

  // STATE CHANGE

  void addQuantity(ProductQuantityModel quantity) {
    Database.service.update(Collections.menu, {
      '$prefix.quantities.${quantity.id}': quantity.toMap(),
    });

    quantities[quantity.id] = quantity;
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
    return quantities.containsKey(id);
  }

  // GETTER

  bool get isReady => ingredientId != null;
  bool get isNotReady => ingredientId == null;
  String get prefix => '${product.prefix}.ingredients';
  String get id => ingredientId;
}
