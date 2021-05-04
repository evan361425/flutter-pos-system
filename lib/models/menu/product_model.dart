import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:possystem/helper/util.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/services/database.dart';

import 'catalog_model.dart';
import 'product_ingredient_model.dart';

class ProductModel extends ChangeNotifier {
  ProductModel({
    @required this.index,
    @required this.name,
    this.catalog,
    this.cost = 0,
    this.price = 0,
    DateTime createdAt,
    String id,
    Map<String, ProductIngredientModel> ingredients,
  })  : createdAt = createdAt ?? DateTime.now(),
        ingredients = ingredients ?? {},
        id = id ?? Util.uuidV4();

  int index;
  String name;
  CatalogModel catalog;
  num cost;
  num price;
  final DateTime createdAt;
  final String id;
  final Map<String, ProductIngredientModel> ingredients;

  factory ProductModel.fromMap(ProductObject object) {
    final product = ProductModel(
      id: object.id,
      name: object.name,
      index: object.index,
      price: object.price,
      cost: object.cost,
      createdAt: object.createdAt,
      ingredients: {
        for (var ingredient in object.ingredients)
          ingredient.id: ProductIngredientModel.fromObject(ingredient)
      },
    );

    product.ingredients.values.forEach((e) {
      e.product = product;
    });

    return product;
  }

  ProductObject toObject() {
    return ProductObject(
      id: id,
      name: name,
      index: index,
      price: price,
      cost: cost,
      createdAt: createdAt,
      ingredients: ingredients.values.map((e) => e.toObject()),
    );
  }

  Future<void> update(ProductObject product) {
    final updateData = product.diff(this);

    if (updateData.isEmpty) return Future.value();

    notifyListeners();

    return Database.instance.update(Collections.menu, updateData);
  }

  void updateIngredient(ProductIngredientModel ingredient) {
    if (!ingredients.containsKey(ingredient.id)) {
      ingredients[ingredient.id] = ingredient;

      final updateData = {ingredient.prefix: ingredient.toObject().toMap()};
      Database.instance.update(Collections.menu, updateData);
    }

    notifyListeners();
  }

  void removeIngredient(ProductIngredientModel ingredient) {
    print('remove product ingredient ${ingredient.id}');
    ingredients.remove(id);

    Database.instance.update(Collections.menu, {ingredient.prefix: null});

    notifyListeners();
  }

  bool has(String id) => ingredients.containsKey(id);

  ProductIngredientModel operator [](String id) => ingredients[id];

  Iterable<ProductIngredientModel> get ingredientsWithQuantity {
    return ingredients.values.where((e) => e.quantities.isNotEmpty);
  }

  String get prefix => '${catalog.id}.products.$id';
}
