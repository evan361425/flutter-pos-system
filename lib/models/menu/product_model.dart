import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:possystem/helper/util.dart';
import 'package:possystem/services/database.dart';

import 'catalog_model.dart';
import 'product_ingredient_model.dart';

class ProductModel extends ChangeNotifier {
  ProductModel({
    @required this.name,
    @required this.catalog,
    this.index = 0,
    this.price = 0,
    this.cost = 0,
    String id,
    Map<String, ProductIngredientModel> ingredients,
    Timestamp createdAt,
  })  : createdAt = createdAt ?? Timestamp.now(),
        ingredients = ingredients ?? {},
        id = id ?? Util.uuidV4();

  String name;
  int index;
  num price;
  num cost;
  final String id;
  final Map<String, ProductIngredientModel> ingredients;
  final CatalogModel catalog;
  final Timestamp createdAt;

  // I/O

  factory ProductModel.fromMap({
    CatalogModel catalog,
    Map<String, dynamic> data,
  }) {
    final oriIngredients = data['ingredients'];
    final ingredients = <String, ProductIngredientModel>{};
    final product = ProductModel(
      catalog: catalog,
      ingredients: ingredients,
      id: data['id'],
      name: data['name'],
      index: data['index'],
      price: data['price'],
      createdAt: data['createdAt'],
    );

    if (oriIngredients is Map) {
      oriIngredients.forEach((final ingredientId, final ingredient) {
        if (ingredient is Map) {
          ingredients[ingredientId] = ProductIngredientModel.fromMap(
            product: product,
            ingredientId: ingredientId,
            data: ingredient,
          );
        }
      });
    }

    return product;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'index': index,
      'price': price,
      'cost': cost,
      'createdAt': createdAt,
      'ingredients': {
        for (var entry in ingredients.entries) entry.key: entry.value.toMap()
      }
    };
  }

  // STATE CHANGE

  void updateIngredient(ProductIngredientModel ingredient) {
    if (!ingredients.containsKey(ingredient.id)) {
      ingredients[ingredient.id] = ingredient;
      final updateData = {
        '$prefix.ingredients.${ingredient.id}': ingredient.toMap()
      };

      Database.service.update(Collections.menu, updateData);
    }
    ingredientChanged();
  }

  void removeIngredient(ProductIngredientModel ingredient) {
    ingredients.remove(ingredient.id);
    final updateData = {'$prefix.ingredients.${ingredient.id}': null};
    Database.service.update(Collections.menu, updateData);
    ingredientChanged();
  }

  void update({
    String name,
    int index,
    num price,
    num cost,
  }) {
    final updateData = _getUpdateData(
      name: name,
      index: index,
      price: price,
      cost: cost,
    );

    if (updateData.isEmpty) return;

    Database.service.update(Collections.menu, updateData);

    notifyListeners();
  }

  void ingredientChanged() {
    catalog.productChanged();
    notifyListeners();
  }

  // HELPER

  Map<String, dynamic> _getUpdateData({
    String name,
    int index,
    num price,
    num cost,
  }) {
    final updateData = <String, dynamic>{};
    if (index != null && index != this.index) {
      this.index = index;
      updateData['$prefix.index'] = index;
    }
    if (price != null && price != this.price) {
      this.price = price;
      updateData['$prefix.price'] = price;
    }
    if (cost != null && cost != this.cost) {
      this.cost = cost;
      updateData['$prefix.cost'] = cost;
    }
    if (name != null && name != this.name) {
      this.name = name;
      updateData['$prefix.name'] = name;
    }
    return updateData;
  }

  bool has(String id) => ingredients.containsKey(id);
  ProductIngredientModel operator [](String id) => ingredients[id];

  // GETTER

  bool get isReady => name != null;
  String get prefix => '${catalog.id}.products.$id';
}
