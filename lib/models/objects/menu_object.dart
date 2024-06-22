import 'package:possystem/helpers/util.dart';

import '../menu/catalog.dart';
import '../menu/product.dart';
import '../menu/product_ingredient.dart';
import '../menu/product_quantity.dart';
import '../model_object.dart';
import '../repository/quantities.dart';
import '../repository/stock.dart';
import '../stock/ingredient.dart';
import '../stock/quantity.dart';

class CatalogObject extends ModelObject<Catalog> {
  final String? id;
  final int? index;
  final String name;
  final String? imagePath;
  final DateTime? createdAt;
  final List<ProductObject> products;

  CatalogObject({
    this.id,
    this.index,
    required this.name,
    this.imagePath,
    this.createdAt,
    List<ProductObject>? products,
  }) : products = products ?? const [];

  factory CatalogObject.build(Map<String, Object?> data) {
    final products = (data['products'] ?? <String, Object?>{}) as Map<String, Object?>;

    return CatalogObject(
      id: data['id'] as String,
      index: data['index'] as int,
      name: data['name'] as String,
      imagePath: data['imagePath'] as String?,
      createdAt: Util.fromUTC(data['createdAt'] as int),
      products: products.entries
          .map<ProductObject>((e) => ProductObject.build({
                'id': e.key,
                ...e.value as Map<String, Object?>,
              }))
          .toList(),
    );
  }

  @override
  Map<String, Object> diff(Catalog model) {
    final result = <String, Object>{};
    final prefix = model.prefix;
    if (name != model.name) {
      model.name = name;
      result['$prefix.name'] = name;
    }
    if (imagePath != null && imagePath != model.imagePath) {
      model.imagePath = imagePath;
      result['$prefix.imagePath'] = imagePath!;
    }
    return result;
  }

  @override
  Map<String, Object?> toMap() {
    return {
      'index': index!,
      'name': name,
      'createdAt': Util.toUTC(now: createdAt),
      'imagePath': imagePath,
      'products': {for (var product in products) product.id: product.toMap()}
    };
  }
}

class ProductIngredientObject extends ModelObject<ProductIngredient> {
  static const latestVersion = 2;

  final String? id;
  final String? ingredientId;
  final int? index;
  final num? amount;
  final List<ProductQuantityObject> quantities;

  /// Version of object
  ///
  /// 1: Using [Ingredient]'s id as id
  /// 2: Generate id for [ProductIngredient]
  final int version;

  ProductIngredientObject({
    this.id,
    this.ingredientId,
    this.index,
    this.amount,
    List<ProductQuantityObject>? quantities,
    this.version = 2,
  }) : quantities = quantities ?? const [];

  factory ProductIngredientObject.build(Map<String, Object?> data) {
    final version = data['ingredientId'] == null ? 1 : 2;
    final id = version == 1 ? Util.uuidV4() : data['id'];
    final ingredientId = version == 1 ? data['id'] : data['ingredientId'];

    final quantities = (data['quantities'] ?? <String, Object?>{}) as Map<String, Object?>;

    return ProductIngredientObject(
      id: id as String,
      ingredientId: ingredientId as String,
      index: data['index'] as int? ?? 0,
      amount: data['amount'] as num,
      version: version,
      quantities: quantities.entries
          .map((e) => ProductQuantityObject.build({
                'id': e.key,
                ...e.value as Map<String, Object?>,
              }))
          .toList(),
    );
  }

  bool get isLatest => version == latestVersion;

  @override
  Map<String, Object> diff(ProductIngredient model) {
    final result = <String, Object>{};
    final prefix = model.prefix;

    if (amount != null && amount != model.amount) {
      model.amount = amount!;
      result['$prefix.amount'] = amount!;
    }
    if (ingredientId != null && ingredientId != model.ingredient.id) {
      model.ingredient = Stock.instance.getItem(ingredientId!)!;
      result['$prefix.ingredientId'] = ingredientId!;
    }

    return result;
  }

  @override
  Map<String, Object> toMap() {
    return {
      'index': index ?? 0,
      'ingredientId': ingredientId!,
      'amount': amount!,
      'quantities': {for (var quantity in quantities) quantity.id: quantity.toMap()},
    };
  }
}

class ProductObject extends ModelObject<Product> {
  final String? id;
  final String? name;
  final int? index;
  final num? price;
  final num? cost;
  final String? imagePath;
  final DateTime? createdAt;
  final DateTime? searchedAt;
  final List<ProductIngredientObject> ingredients;

  ProductObject({
    this.id,
    this.name,
    this.index,
    this.price,
    this.cost,
    this.imagePath,
    this.createdAt,
    this.searchedAt,
    List<ProductIngredientObject>? ingredients,
  }) : ingredients = ingredients ?? const [];

  factory ProductObject.build(Map<String, Object?> data) {
    final ingredients = (data['ingredients'] ?? <String, Object?>{}) as Map<String, Object?>;
    final searchedAt = data['searchedAt'] as int?;

    return ProductObject(
      id: data['id'] as String,
      name: data['name'] as String,
      index: data['index'] as int,
      price: data['price'] as num,
      cost: data['cost'] as num,
      imagePath: data['imagePath'] as String?,
      createdAt: Util.fromUTC(data['createdAt'] as int),
      searchedAt: searchedAt == null ? null : Util.fromUTC(searchedAt),
      ingredients: ingredients.entries
          .map<ProductIngredientObject>((e) => ProductIngredientObject.build({
                'id': e.key,
                ...e.value as Map<String, Object?>,
              }))
          .toList(),
    );
  }

  @override
  Map<String, Object> diff(Product model) {
    final result = <String, Object>{};
    final prefix = model.prefix;
    if (price != null && price != model.price) {
      model.price = price!;
      result['$prefix.price'] = price!;
    }
    if (cost != null && cost != model.cost) {
      model.cost = cost!;
      result['$prefix.cost'] = cost!;
    }
    if (name != null && name != model.name) {
      model.name = name!;
      result['$prefix.name'] = name!;
    }
    if (searchedAt != null && searchedAt != model.searchedAt) {
      model.searchedAt = searchedAt;
      result['$prefix.searchedAt'] = Util.toUTC(now: searchedAt);
    }
    if (imagePath != null && imagePath != model.imagePath) {
      model.imagePath = imagePath;
      result['$prefix.imagePath'] = imagePath!;
    }
    return result;
  }

  @override
  Map<String, Object?> toMap() {
    return {
      'price': price!,
      'cost': cost!,
      'index': index!,
      'name': name!,
      'imagePath': imagePath,
      'createdAt': Util.toUTC(now: createdAt),
      if (searchedAt != null) 'searchedAt': Util.toUTC(now: searchedAt),
      'ingredients': {for (var ingredient in ingredients) ingredient.id: ingredient.toMap()}
    };
  }
}

class ProductQuantityObject extends ModelObject<ProductQuantity> {
  static const latestVersion = 2;

  final String? id;
  final String? quantityId;
  final num? amount;
  final num? additionalCost;
  final num? additionalPrice;

  /// Version of object
  ///
  /// 1: Using [Quantity]'s id as id
  /// 2: Generate id for [ProductQuantity]
  final int version;

  ProductQuantityObject({
    this.id,
    this.quantityId,
    this.amount,
    this.additionalCost,
    this.additionalPrice,
    this.version = 2,
  });

  /// Build [ProductQuantityObject] by map data.
  ///
  /// Old version storage has no [quantityId], it should generate new
  /// [id] and take [id] as [quantityId]
  factory ProductQuantityObject.build(Map<String, Object?> data) {
    final version = data['quantityId'] == null ? 1 : 2;
    final id = version == 1 ? Util.uuidV4() : data['id'];
    final quantityId = version == 1 ? data['id'] : data['quantityId'];

    return ProductQuantityObject(
      id: id as String,
      quantityId: quantityId as String,
      amount: data['amount'] as num? ?? 0,
      additionalCost: data['additionalCost'] as num? ?? 0,
      additionalPrice: data['additionalPrice'] as num? ?? 0,
      version: version,
    );
  }

  bool get isLatest => version == latestVersion;

  @override
  Map<String, Object> diff(ProductQuantity model) {
    final result = <String, Object>{};
    final prefix = model.prefix;

    if (amount != null && amount != model.amount) {
      model.amount = amount!;
      result['$prefix.amount'] = amount!;
    }
    if (additionalCost != null && additionalCost != model.additionalCost) {
      model.additionalCost = additionalCost!;
      result['$prefix.additionalCost'] = additionalCost!;
    }
    if (additionalPrice != null && additionalPrice != model.additionalPrice) {
      model.additionalPrice = additionalPrice!;
      result['$prefix.additionalPrice'] = additionalPrice!;
    }
    if (quantityId != null && quantityId != model.quantity.id) {
      model.quantity = Quantities.instance.getItem(quantityId!)!;
      result['$prefix.quantityId'] = quantityId!;
    }

    return result;
  }

  @override
  Map<String, Object> toMap() {
    return {
      'quantityId': quantityId!,
      'amount': amount!,
      'additionalCost': additionalCost!,
      'additionalPrice': additionalPrice!,
    };
  }
}
