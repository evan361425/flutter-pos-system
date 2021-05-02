import 'package:flutter/material.dart';
import 'package:possystem/models/maps/menu_map.dart';
import 'package:possystem/models/menu/product_quantity_model.dart';
import 'package:possystem/models/stock/ingredient_model.dart';
import 'package:possystem/services/database.dart';

import 'product_model.dart';

class ProductIngredientModel {
  ProductIngredientModel({
    this.ingredientId,
    this.ingredient,
    this.product,
    num amount,
    num cost,
    Map<String, ProductQuantityModel> quantities,
  })  : quantities = quantities ?? {},
        amount = amount ?? 0,
        cost = cost ?? 0 {
    ingredientId ??= ingredient.id;
  }

  final Map<String, ProductQuantityModel> quantities;
  ProductModel product;
  String ingredientId;
  num amount;
  num cost;
  IngredientModel ingredient;

  factory ProductIngredientModel.fromMap(ProductIngredientMap map) {
    return ProductIngredientModel(
      ingredientId: map.id,
      amount: map.amount,
      cost: map.cost,
      quantities: {
        for (var quantity in map.quantities)
          quantity.id: ProductQuantityModel.fromMap(quantity)
      },
    );
  }

  factory ProductIngredientModel.empty(ProductModel product) {
    return ProductIngredientModel(product: product, ingredientId: null);
  }

  ProductIngredientMap toMap() {
    return ProductIngredientMap(
      id: id,
      cost: cost,
      amount: amount,
      quantities: quantities.values.map((e) => e.toMap()),
    );
  }

  // STATE CHANGE

  void updateQuantity(ProductQuantityModel quantity) {
    print('update quantity ${quantity.id}');
    if (!quantities.containsKey(quantity.id)) {
      quantities[quantity.id] = quantity;
      final updateData = {
        '$prefixQuantities.${quantity.id}': quantity.toMap(),
      };

      Database.instance.update(Collections.menu, updateData);
    }

    product.ingredientChanged();
  }

  ProductQuantityModel removeQuantity(String id) {
    print('remove quantity $id');

    final quantity = quantities.remove(id);
    final updateData = {'$prefixQuantities.$id': null};
    Database.instance.update(Collections.menu, updateData);
    product.ingredientChanged();

    return quantity;
  }

  void update({
    num amount,
    num cost,
    IngredientModel ingredient,
  }) {
    final updateData = <String, dynamic>{};
    if (amount != this.amount) {
      this.amount = amount;
      updateData['$prefix.amount'] = amount;
    }
    if (cost != this.cost) {
      this.cost = cost;
      updateData['$prefix.cost'] = cost;
    }
    // after all property set
    if (id != ingredient.id) {
      product.removeIngredient(id);

      ingredientId = ingredient.id;
      this.ingredient = ingredient;

      updateData.clear();
    }

    if (updateData.isEmpty) return;

    Database.instance.update(Collections.menu, updateData);
  }

  // HELPER

  bool has(String id) => quantities.containsKey(id);
  ProductQuantityModel operator [](String id) => quantities[id];

  // GETTER

  bool get isReady => ingredientId != null;
  bool get isNotReady => ingredientId == null;
  String get id => ingredientId;
  String get prefix => '${product.prefix}.ingredients.$id';
  String get prefixQuantities => '$prefix.quantities';
}
