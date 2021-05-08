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

  Map<String, dynamic> toMap() {
    return {
      'index': index,
      'name': name,
      'createdAt': createdAt.toString(),
      'products': {for (var product in products) product.id: product.toMap()}
    };
  }

  Map<String, dynamic> diff(CatalogModel catalog) {
    final result = <String, dynamic>{};
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

  factory CatalogObject.build(Map<String, dynamic> data) {
    Map<String, Map<String, dynamic>> products = data['products'];

    return CatalogObject(
      id: data['id'],
      index: data['index'],
      name: data['name'],
      createdAt: Util.parseDate(data['createdAt']),
      products: products?.entries?.map<ProductObject>(
        (e) => ProductObject.build({'id': e.key, ...e.value}),
      ),
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

  Map<String, dynamic> toMap() {
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

  Map<String, dynamic> diff(ProductModel product) {
    final result = <String, dynamic>{};
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

  factory ProductObject.build(Map<String, dynamic> data) {
    return ProductObject(
      id: data['id'],
      price: data['price'],
      cost: data['cost'],
      index: data['index'],
      name: data['name'],
      createdAt: Util.parseDate(data['createdAt']),
      ingredients: data['ingredients']?.entries?.map<ProductIngredientObject>(
            (e) => ProductIngredientObject.build({'id': e.key, ...e.value}),
          ),
    );
  }
}

class ProductIngredientObject {
  ProductIngredientObject({
    this.id,
    this.amount,
    this.cost,
    Iterable<ProductQuantityObject> quantities,
  }) : quantities = quantities ?? Iterable.empty();

  final String id;
  final num amount;
  final num cost;
  final Iterable<ProductQuantityObject> quantities;

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'cost': cost,
      'quantities': {
        for (var quantity in quantities) quantity.id: quantity.toMap()
      },
    };
  }

  Map<String, dynamic> diff(ProductIngredientModel ingredient) {
    final result = <String, dynamic>{};
    final prefix = ingredient.prefix;

    if (amount != null && amount != ingredient.amount) {
      ingredient.amount = amount;
      result['$prefix.amount'] = amount;
    }
    if (cost != null && cost != ingredient.cost) {
      ingredient.cost = cost;
      result['$prefix.cost'] = cost;
    }
    // after all property set
    if (id != null && id != ingredient.id) {
      ingredient.changeIngredient(id);

      return {ingredient.prefix: ingredient.toObject().toMap()};
    }

    return result;
  }

  factory ProductIngredientObject.build(Map<String, dynamic> data) {
    Map<String, Map<String, dynamic>> quantities = data['quantities'];
    return ProductIngredientObject(
      id: data['id'],
      amount: data['amount'],
      cost: data['cost'],
      quantities: quantities?.entries?.map<ProductQuantityObject>(
        (e) => ProductQuantityObject.build({'id': e.key, ...e.value}),
      ),
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

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'additionalCost': additionalCost,
      'additionalPrice': additionalPrice,
    };
  }

  Map<String, dynamic> diff(
    ProductIngredientModel ingredient,
    ProductQuantityModel quantity,
  ) {
    final result = <String, dynamic>{};
    final prefix = '${ingredient.prefixQuantities}.${quantity.id}';

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
      quantity.changeQuantity(ingredient, id);

      return {
        '${ingredient.prefixQuantities}.$id': quantity.toObject().toMap(),
      };
    }

    return result;
  }

  factory ProductQuantityObject.build(Map<String, dynamic> data) {
    return ProductQuantityObject(
      id: data['id'],
      amount: data['amount'],
      additionalCost: data['additionalCost'],
      additionalPrice: data['additionalPrice'],
    );
  }
}
