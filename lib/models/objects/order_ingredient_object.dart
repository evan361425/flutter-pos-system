import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/objects/order_serializable.dart';

/// Product single ingredient details in object mode, helps I/O in DB.
class OrderIngredientObject extends OrderSerializable {
  /// ID of database row
  final int id;

  /// Ingredient's name.
  final String ingredientName;

  /// Quantity's name. Default to null means using default quantity.
  final String? quantityName;

  /// Price addition by this ingredient and quantity.
  final num additionalPrice;

  /// Cost addition by this ingredient and quantity.
  final num additionalCost;

  /// The amount of ingredient which will reduce the stock amount after ordered.
  final num amount;

  /// Ingredient ID mapping to stock, help to calculate stock amounts.
  final String ingredientId;

  /// Ingredient ID mapping to product, help to restore from stash,
  final String productIngredientId;

  /// Quantity ID mapping to product, help to restore from stash.
  final String? productQuantityId;

  const OrderIngredientObject({
    this.id = 0,
    this.ingredientName = '',
    this.quantityName,
    this.additionalPrice = 0,
    this.additionalCost = 0,
    this.amount = 0,
    this.ingredientId = '',
    this.productIngredientId = '',
    this.productQuantityId,
  });

  @override
  Map<String, Object?> toMap() {
    return {
      'ingredientName': ingredientName,
      'quantityName': quantityName,
      'additionalPrice': additionalPrice,
      'additionalCost': additionalCost,
      'amount': amount,
    };
  }

  @override
  Map<String, Object?> toStashMap() {
    return {
      'productIngredientId': productIngredientId,
      'productQuantityId': productQuantityId,
    };
  }

  /// Create object from DB format.
  factory OrderIngredientObject.fromMap(Map<String, dynamic> data) {
    // null-safety to make test easy
    return OrderIngredientObject(
      id: data['id'] as int? ?? 0,
      ingredientName: data['ingredientName'] as String? ?? '',
      quantityName: data['quantityName'] as String?,
      additionalPrice: data['additionalPrice'] as num? ?? 0,
      additionalCost: data['additionalCost'] as num? ?? 0,
      amount: data['amount'] as num? ?? 0,
    );
  }

  /// Create object from DB format.
  factory OrderIngredientObject.fromStashMap(Map<String, dynamic> data) {
    return OrderIngredientObject(
      productIngredientId: data['productIngredientId'],
      productQuantityId: data['productQuantityId'],
    );
  }

  /// Create object from model.
  factory OrderIngredientObject.fromModel(
    ProductIngredient ingredient,
    String? quantityId,
  ) {
    final quantity = quantityId == null ? null : ingredient.getItem(quantityId);

    return OrderIngredientObject(
      ingredientName: ingredient.name,
      quantityName: quantity?.name,
      amount: quantity?.amount ?? ingredient.amount,
      additionalPrice: quantity?.additionalPrice ?? 0,
      additionalCost: quantity?.additionalCost ?? 0,
      ingredientId: ingredient.ingredient.id,
      productIngredientId: ingredient.id,
      productQuantityId: quantity?.id,
    );
  }
}
