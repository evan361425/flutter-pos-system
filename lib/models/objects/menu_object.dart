import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/model_object.dart';

class CatalogObject extends ModelObject<Catalog> {
  CatalogObject({
    this.id,
    this.index,
    required this.name,
    this.createdAt,
    Iterable<ProductObject>? products,
  }) : products = products ?? Iterable.empty();

  final String? id;
  final int? index;
  final String name;
  final DateTime? createdAt;
  final Iterable<ProductObject> products;

  @override
  Map<String, Object> toMap() {
    return {
      'index': index!,
      'name': name,
      'createdAt': Util.toUTC(now: createdAt),
      'products': {for (var product in products) product.id: product.toMap()}
    };
  }

  @override
  Map<String, Object> diff(Catalog catalog) {
    final result = <String, Object>{};
    final prefix = catalog.prefix;
    if (index != null && index != catalog.index) {
      catalog.index = index!;
      result['$prefix.index'] = index!;
    }
    if (name != catalog.name) {
      catalog.name = name;
      result['$prefix.name'] = name;
    }
    return result;
  }

  factory CatalogObject.build(Map<String, Object?> data) {
    final products =
        (data['products'] ?? <String, Object?>{}) as Map<String, Object?>;

    return CatalogObject(
      id: data['id'] as String,
      index: data['index'] as int,
      name: data['name'] as String,
      createdAt: Util.fromUTC(data['createdAt'] as int),
      products: products.entries
          // sembast can't delete map entry, filter null value
          .where((e) => e.value != null)
          .map<ProductObject>((e) => ProductObject.build({
                'id': e.key,
                ...e.value as Map<String, Object?>,
              })),
    );
  }
}

class ProductObject extends ModelObject<Product> {
  ProductObject({
    this.id,
    this.name,
    this.index,
    this.price,
    this.cost,
    this.createdAt,
    this.searchedAt,
    Iterable<ProductIngredientObject>? ingredients,
  }) : ingredients = ingredients ?? Iterable.empty();

  final String? id;
  final String? name;
  final int? index;
  final num? price;
  final num? cost;
  final DateTime? createdAt;
  final DateTime? searchedAt;
  final Iterable<ProductIngredientObject> ingredients;

  @override
  Map<String, Object> toMap() {
    return {
      'price': price!,
      'cost': cost!,
      'index': index!,
      'name': name!,
      'createdAt': Util.toUTC(now: createdAt),
      if (searchedAt != null) 'searchedAt': Util.toUTC(now: searchedAt),
      'ingredients': {
        for (var ingredient in ingredients) ingredient.id: ingredient.toMap()
      }
    };
  }

  @override
  Map<String, Object> diff(Product product) {
    final result = <String, Object>{};
    final prefix = product.prefix;
    if (price != null && price != product.price) {
      product.price = price!;
      result['$prefix.price'] = price!;
    }
    if (cost != null && cost != product.cost) {
      product.cost = cost!;
      result['$prefix.cost'] = cost!;
    }
    if (name != null && name != product.name) {
      product.name = name!;
      result['$prefix.name'] = name!;
    }
    if (searchedAt != null && searchedAt != product.searchedAt) {
      product.searchedAt = searchedAt;
      result['$prefix.searchedAt'] = Util.toUTC(now: searchedAt);
    }
    return result;
  }

  factory ProductObject.build(Map<String, Object?> data) {
    final ingredients =
        (data['ingredients'] ?? <String, Object?>{}) as Map<String, Object?>;
    final searchedAt = data['searchedAt'] as int?;

    return ProductObject(
      id: data['id'] as String,
      name: data['name'] as String,
      index: data['index'] as int,
      price: data['price'] as num,
      cost: data['cost'] as num,
      createdAt: Util.fromUTC(data['createdAt'] as int),
      searchedAt: searchedAt == null ? null : Util.fromUTC(searchedAt),
      ingredients: ingredients.entries
          // sembast can't delete map entry, filter null value
          .where((e) => e.value != null)
          .map<ProductIngredientObject>((e) => ProductIngredientObject.build({
                'id': e.key,
                ...e.value as Map<String, Object?>,
              })),
    );
  }
}

class ProductIngredientObject extends ModelObject<ProductIngredient> {
  ProductIngredientObject({
    this.id,
    this.amount,
    Iterable<ProductQuantityObject>? quantities,
  }) : quantities = quantities ?? Iterable.empty();

  final String? id;
  final num? amount;
  final Iterable<ProductQuantityObject> quantities;

  @override
  Map<String, Object> toMap() {
    return {
      'id': id!,
      'amount': amount!,
      'quantities': {
        for (var quantity in quantities) quantity.id: quantity.toMap()
      },
    };
  }

  @override
  Map<String, Object> diff(ProductIngredient ingredient) {
    final result = <String, Object>{};
    final prefix = ingredient.prefix;

    if (amount != null && amount != ingredient.amount) {
      ingredient.amount = amount!;
      result['$prefix.amount'] = amount!;
    }
    // after all property set
    if (id != null && id != ingredient.id) {
      return {'id': ingredient.changeIngredient(id!)};
    }

    return result;
  }

  factory ProductIngredientObject.build(Map<String, Object?> data) {
    final quantities =
        (data['quantities'] ?? <String, Object?>{}) as Map<String, Object?>;

    return ProductIngredientObject(
      id: data['id'] as String,
      amount: data['amount'] as num,
      quantities: quantities.entries
          // sembast can't delete map entry, filter null value
          .where((e) => e.value != null)
          .map<ProductQuantityObject>((e) => ProductQuantityObject.build({
                'id': e.key,
                ...e.value as Map<String, Object?>,
              })),
    );
  }
}

class ProductQuantityObject extends ModelObject<ProductQuantity> {
  ProductQuantityObject({
    this.id,
    required this.amount,
    required this.additionalCost,
    required this.additionalPrice,
  });

  final String? id;
  final num amount;
  final num additionalCost;
  final num additionalPrice;

  @override
  Map<String, Object> toMap() {
    return {
      'amount': amount,
      'additionalCost': additionalCost,
      'additionalPrice': additionalPrice,
    };
  }

  @override
  Map<String, Object> diff(ProductQuantity quantity) {
    final result = <String, Object>{};
    final prefix = quantity.prefix;

    if (amount != quantity.amount) {
      quantity.amount = amount;
      result['$prefix.amount'] = amount;
    }
    if (additionalCost != quantity.additionalCost) {
      quantity.additionalCost = additionalCost;
      result['$prefix.additionalCost'] = additionalCost;
    }
    if (additionalPrice != quantity.additionalPrice) {
      quantity.additionalPrice = additionalPrice;
      result['$prefix.additionalPrice'] = additionalPrice;
    }
    // after all property set
    if (id != null && id != quantity.id) {
      return {'id': quantity.changeQuantity(id!)};
    }

    return result;
  }

  factory ProductQuantityObject.build(Map<String, Object?> data) {
    return ProductQuantityObject(
      id: data['id'] as String,
      amount: data['amount'] as num,
      additionalCost: data['additionalCost'] as num,
      additionalPrice: data['additionalPrice'] as num,
    );
  }
}
