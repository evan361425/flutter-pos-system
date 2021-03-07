import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:possystem/services/database.dart';

import 'catalog_model.dart';
import 'ingredient_model.dart';

class ProductModel extends ChangeNotifier {
  ProductModel({
    @required this.id,
    @required this.name,
    @required this.catalog,
    this.index = 0,
    this.price = 0,
    this.cost = 0,
    Map<String, IngredientModel> ingredients,
    Timestamp createdAt,
  })  : createdAt = createdAt ?? Timestamp.now(),
        ingredients = ingredients ?? {};

  int id;
  String name;
  int index;
  num price;
  num cost;
  final Map<String, IngredientModel> ingredients;
  final CatalogModel catalog;
  final Timestamp createdAt;

  // I/O

  factory ProductModel.fromMap({
    CatalogModel catalog,
    Map<String, dynamic> data,
  }) {
    if (data == null) {
      return ProductModel.empty(data['catalogName']);
    }

    final oriIngredients = data['ingredients'];
    final ingredients = <String, IngredientModel>{};
    final product = ProductModel(
      id: data['id'],
      name: data['name'],
      catalog: catalog,
      index: data['index'],
      price: data['price'],
      createdAt: data['createdAt'],
      ingredients: ingredients,
    );

    if (oriIngredients is Map) {
      oriIngredients.forEach((final key, final ingredient) {
        if (ingredient is Map) {
          ingredients[key] = IngredientModel.fromMap(
            product: product,
            name: key,
            data: ingredient,
          );
        }
      });
    }

    return product;
  }

  factory ProductModel.empty(CatalogModel catalog) {
    return ProductModel(
      id: catalog.newId,
      name: null,
      catalog: catalog,
      index: catalog.newIndex,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'index': index,
      'price': price,
      'createdAt': createdAt,
      'ingredients': {
        for (var entry in ingredients.entries) entry.key: entry.value.toMap()
      }
    };
  }

  // STATE CHANGE

  Future<void> addIngredient(IngredientModel ingredient) async {
    await Database.service.update(Collections.menu, {
      '$prefix.ingredients.${ingredient.name}': ingredient.toMap(),
    });

    ingredients[ingredient.name] = ingredient;
    notifyListeners();
  }

  Future<void> update({
    String name,
    int index,
    num price,
    num cost,
    bool updateDB = true,
  }) async {
    final updateData = getUpdateData(
      name: name,
      index: index,
      price: price,
      cost: cost,
    );
    if (updateData.isEmpty) return;

    if (!updateDB) {
      this.name = name;
      return;
    }

    return Database.service.update(Collections.menu, updateData).then((_) {
      if (name == this.name) {
        catalog.changeProduct();
      } else {
        catalog.changeProduct(oldName: this.name, newName: name);
        this.name = name;
      }
      notifyListeners();
    });
  }

  void changeIngredient({String oldName, String newName}) {
    if (oldName != null && oldName != newName) {
      ingredients[newName] = ingredients[oldName];
      ingredients.remove(oldName);
    }

    notifyListeners();
    catalog.changeProduct();
  }

  // HELPER

  bool has(String name) => ingredients.containsKey(name);

  Map<String, dynamic> getUpdateData({
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
      updateData.clear();
      updateData[prefix] = FieldValue.delete();
      updateData['${catalog.name}.products.$name'] = toMap();
    }
    return updateData;
  }

  // GETTER

  bool get isReady => name != null;

  String get prefix => '${catalog.name}.products.$name';
}
