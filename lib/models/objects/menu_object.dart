import 'package:possystem/helper/util.dart';
import 'package:possystem/models/menu/catalog_model.dart';
import 'package:possystem/models/menu/product_ingredient_model.dart';
import 'package:possystem/models/menu/product_model.dart';
import 'package:possystem/models/menu/product_quantity_model.dart';

class CatalogObject {
  CatalogObject({
    this.id,
    this.index,
    this.name,
    this.createdAt,
    Iterable<ProductObject> products,
  }) : products = products ?? Iterable.empty();

  final String id;
  final int index;
  final String name;
  final DateTime createdAt;
  final Iterable<ProductObject> products;

  Map<String, Object> toMap() {
    return {
      'index': index,
      'name': name,
      'createdAt': createdAt.toString(),
      'products': {for (var product in products) product.id: product.toMap()}
    };
  }

  Map<String, Object> diff(CatalogModel catalog) {
    final result = <String, Object>{};
    if (index != null && index != catalog.index) {
      catalog.index = index;
      result['$id.index'] = index;
    }
    if (name != null && name != catalog.name) {
      catalog.name = name;
      result['$id.name'] = name;
    }
    return result;
  }

  factory CatalogObject.build(Map<String, Object> data) {
    final Map<String, Object> products = data['products'];

    return CatalogObject(
      id: data['id'],
      index: data['index'],
      name: data['name'],
      createdAt: Util.parseDate(data['createdAt']),
      products: products.entries
          // sembast can't delete map entry, filter null value
          .where((e) => e.value != null)
          .map<ProductObject>((e) => ProductObject.build({
                'id': e.key,
                ...e.value as Map,
              })),
    );
  }
}

class ProductObject {
  ProductObject({
    this.id,
    this.price,
    this.cost,
    this.index,
    this.name,
    this.createdAt,
    this.ingredients,
  });

  final String id;
  final num price;
  final num cost;
  final int index;
  final String name;
  final DateTime createdAt;
  final Iterable<ProductIngredientObject> ingredients;

  Map<String, Object> toMap() {
    return {
      'price': price,
      'cost': cost,
      'index': index,
      'name': name,
      'createdAt': createdAt.toString(),
      'ingredients': {
        for (var ingredient in ingredients) ingredient.id: ingredient.toMap()
      }
    };
  }

  Map<String, Object> diff(ProductModel product) {
    final result = <String, Object>{};
    final prefix = product.prefix;
    if (index != null && index != product.index) {
      product.index = index;
      result['$prefix.index'] = index;
    }
    if (price != null && price != product.price) {
      product.price = price;
      result['$prefix.price'] = price;
    }
    if (cost != null && cost != product.cost) {
      product.cost = cost;
      result['$prefix.cost'] = cost;
    }
    if (name != null && name != product.name) {
      product.name = name;
      result['$prefix.name'] = name;
    }
    return result;
  }

  factory ProductObject.build(Map<String, Object> data) {
    final Map<String, Object> ingredients = data['ingredients'];

    return ProductObject(
      id: data['id'],
      price: data['price'],
      cost: data['cost'],
      index: data['index'],
      name: data['name'],
      createdAt: Util.parseDate(data['createdAt']),
      ingredients: ingredients.entries
          // sembast can't delete map entry, filter null value
          .where((e) => e.value != null)
          .map<ProductIngredientObject>((e) => ProductIngredientObject.build({
                'id': e.key,
                ...e.value as Map,
              })),
    );
  }
}

class ProductIngredientObject {
  ProductIngredientObject({
    this.id,
    this.amount,
    Iterable<ProductQuantityObject> quantities,
  }) : quantities = quantities ?? Iterable.empty();

  final String id;
  final num amount;
  final Iterable<ProductQuantityObject> quantities;

  Map<String, Object> toMap() {
    return {
      'amount': amount,
      'quantities': {
        for (var quantity in quantities) quantity.id: quantity.toMap()
      },
    };
  }

  Map<String, Object> diff(ProductIngredientModel ingredient) {
    final result = <String, Object>{};
    final prefix = ingredient.prefix;

    if (amount != null && amount != ingredient.amount) {
      ingredient.amount = amount;
      result['$prefix.amount'] = amount;
    }
    // after all property set
    if (id != null && id != ingredient.id) {
      ingredient.changeIngredient(id);

      return {ingredient.prefix: ingredient.toObject().toMap()};
    }

    return result;
  }

  factory ProductIngredientObject.build(Map<String, Object> data) {
    Map<String, Object> quantities = data['quantities'];

    return ProductIngredientObject(
      id: data['id'],
      amount: data['amount'],
      quantities: quantities.entries
          // sembast can't delete map entry, filter null value
          .where((e) => e.value != null)
          .map<ProductQuantityObject>((e) => ProductQuantityObject.build({
                'id': e.key,
                ...e.value as Map,
              })),
    );
  }
}

class ProductQuantityObject {
  ProductQuantityObject({
    this.id,
    this.amount,
    this.additionalCost,
    this.additionalPrice,
  });

  final String id;
  final num amount;
  final num additionalCost;
  final num additionalPrice;

  Map<String, Object> toMap() {
    return {
      'amount': amount,
      'additionalCost': additionalCost,
      'additionalPrice': additionalPrice,
    };
  }

  Map<String, Object> diff(ProductQuantityModel quantity) {
    final result = <String, Object>{};
    final prefix = quantity.prefix;

    if (amount != null && amount != quantity.amount) {
      quantity.amount = amount;
      result['$prefix.amount'] = amount;
    }
    if (additionalCost != null && additionalCost != quantity.additionalCost) {
      quantity.additionalCost = additionalCost;
      result['$prefix.additionalCost'] = additionalCost;
    }
    if (additionalPrice != null &&
        additionalPrice != quantity.additionalPrice) {
      quantity.additionalPrice = additionalPrice;
      result['$prefix.additionalPrice'] = additionalPrice;
    }
    // after all property set
    if (id != null && id != quantity.id) {
      quantity.changeQuantity(id);

      return {quantity.prefix: quantity.toObject().toMap()};
    }

    return result;
  }

  factory ProductQuantityObject.build(Map<String, Object> data) {
    return ProductQuantityObject(
      id: data['id'],
      amount: data['amount'],
      additionalCost: data['additionalCost'],
      additionalPrice: data['additionalPrice'],
    );
  }
}
