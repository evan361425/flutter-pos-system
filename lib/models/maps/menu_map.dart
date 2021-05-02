import 'package:flutter/material.dart';

class CatalogMap {
  CatalogMap({
    @required this.id,
    @required this.index,
    @required this.name,
    @required this.createdAt,
    @required this.products,
  });

  final String id;
  final int index;
  final String name;
  final DateTime createdAt;
  final Iterable<ProductMap> products;

  Map<String, dynamic> output() {
    return {
      'index': index,
      'name': name,
      'createdAt': createdAt.toString(),
      'products': {for (var product in products) product.id: product.output()}
    };
  }

  factory CatalogMap.build(Map<String, dynamic> data) {
    Map<String, Map<String, dynamic>> products = data['products'];

    return CatalogMap(
      id: data['id'],
      index: data['index'],
      name: data['name'],
      createdAt: _parseDate(data['createdAt']),
      products: products.entries.map<ProductMap>(
        (e) => ProductMap.build({'id': e.key, ...e.value}),
      ),
    );
  }
}

class ProductMap {
  ProductMap({
    @required this.id,
    @required this.price,
    @required this.cost,
    @required this.index,
    @required this.name,
    @required this.createdAt,
    @required this.ingredients,
  });

  final String id;
  final num price;
  final num cost;
  final int index;
  final String name;
  final DateTime createdAt;
  final Iterable<ProductIngredientMap> ingredients;

  Map<String, dynamic> output() {
    return {
      'price': price,
      'cost': cost,
      'index': index,
      'name': name,
      'createdAt': createdAt.toString(),
      'ingredients': {
        for (var ingredient in ingredients) ingredient.id: ingredient.output()
      }
    };
  }

  factory ProductMap.build(Map<String, dynamic> data) {
    Map<String, Map<String, dynamic>> ingredients = data['ingredients'];

    return ProductMap(
      id: data['id'],
      price: data['price'],
      cost: data['cost'],
      index: data['index'],
      name: data['name'],
      createdAt: _parseDate(data['createdAt']),
      ingredients: ingredients.entries.map<ProductIngredientMap>(
        (e) => ProductIngredientMap.build({'id': e.key, ...e.value}),
      ),
    );
  }
}

class ProductIngredientMap {
  ProductIngredientMap({
    @required this.id,
    @required this.amount,
    @required this.cost,
    @required this.quantities,
  });

  final String id;
  final num amount;
  final num cost;
  final Iterable<ProductQuantityMap> quantities;

  Map<String, dynamic> output() {
    return {
      'amount': amount,
      'cost': cost,
      'quantities': {
        for (var quantity in quantities) quantity.id: quantity.output()
      },
    };
  }

  factory ProductIngredientMap.build(Map<String, dynamic> data) {
    Map<String, Map<String, dynamic>> quantities = data['quantities'];
    return ProductIngredientMap(
      id: data['id'],
      amount: data['amount'],
      cost: data['cost'],
      quantities: quantities.entries.map<ProductQuantityMap>(
        (e) => ProductQuantityMap.build({'id': e.key, ...e.value}),
      ),
    );
  }
}

class ProductQuantityMap {
  ProductQuantityMap({
    @required this.id,
    @required this.amount,
    @required this.additionalCost,
    @required this.additionalPrice,
  });

  final String id;
  final num amount;
  final num additionalCost;
  final num additionalPrice;

  Map<String, dynamic> output() {
    return {
      'amount': amount,
      'additionalCost': additionalCost,
      'additionalPrice': additionalPrice,
    };
  }

  factory ProductQuantityMap.build(Map<String, dynamic> data) {
    return ProductQuantityMap(
      id: data['id'],
      amount: data['amount'],
      additionalCost: data['additionalCost'],
      additionalPrice: data['additionalPrice'],
    );
  }
}

DateTime _parseDate(String createdAt) {
  try {
    return DateTime.parse(createdAt);
  } catch (e) {
    return DateTime.now();
  }
}
