import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:possystem/helper/util.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/services/database.dart';

import 'catalog_model.dart';
import 'product_ingredient_model.dart';

class ProductModel extends ChangeNotifier {
  int index;

  String name;

  CatalogModel catalog;

  num cost;

  num price;

  final DateTime createdAt;

  final String id;

  final Map<String, ProductIngredientModel> ingredients;

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

  Iterable<ProductIngredientModel> get ingredientsWithQuantity =>
      ingredients.values.where((e) => e.quantities.isNotEmpty);

  String get prefix => '${catalog.id}.products.$id';

  ProductIngredientModel operator [](String id) => ingredients[id];

  bool has(String id) => ingredients.containsKey(id);

  Future<void> removeIngredient(ProductIngredientModel ingredient) {
    ingredients.remove(ingredient.id);
    print('remove product ingredient ${ingredient.id}');

    notifyListeners();

    return Database.instance
        .update(Collections.menu, {ingredient.prefix: null});
  }

  ProductObject toObject() => ProductObject(
        id: id,
        name: name,
        index: index,
        price: price,
        cost: cost,
        createdAt: createdAt,
        ingredients: ingredients.values.map((e) => e.toObject()),
      );

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

    catalog.notifyListeners();

    notifyListeners();
  }
}
