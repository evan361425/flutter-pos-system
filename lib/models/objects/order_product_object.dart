import 'package:possystem/models/objects/order_ingredient_object.dart';
import 'package:possystem/models/objects/order_serializable.dart';

/// Single product set of the order in object mode, helps I/O in DB.
class OrderProductObject extends OrderSerializable {
  /// ID of database row
  final int id;

  /// ID help to recover from stashed.
  final String productId;

  /// [Menu] product's name
  final String productName;

  /// [Menu] catalog's name
  final String catalogName;

  /// Count of products
  final int count;

  /// Single cost of product, after updated by [Menu] quantity.
  final num singleCost;

  /// Single price of product, after updated by discount.
  final num singlePrice;

  /// Single price of product, original from [Menu].
  final num originalPrice;

  /// Whether it is discount by user.
  final bool isDiscount;

  /// Tax rate snapshot at checkout time (percentage, e.g. 20.0 for 20%).
  final num taxRate;

  /// Per-line kitchen note (allergy / prep instruction).
  final String note;

  /// Ingredients details including default quantity which will have null
  /// quantity properties.
  final List<OrderIngredientObject> ingredients;

  /// product may have multiple count.
  const OrderProductObject({
    this.id = 0,
    this.productId = '',
    this.productName = '',
    this.catalogName = '',
    this.count = 0,
    this.singleCost = 0,
    this.singlePrice = 0,
    this.originalPrice = 0,
    this.isDiscount = false,
    this.taxRate = 0.0,
    this.note = '',
    this.ingredients = const [],
  });

  /// Total price of the products, after updated by discount.
  num get totalPrice => count * singlePrice;

  /// Total cost of the products, after updated by ingredient.
  num get totalCost => count * singleCost;

  /// Tax amount for this line: `(price * qty) * (taxRate / 100)`.
  num get totalTax => totalPrice * (taxRate / 100);

  @override
  Map<String, Object?> toMap() {
    return {
      'productName': productName,
      'catalogName': catalogName,
      'count': count,
      'singleCost': singleCost,
      'singlePrice': singlePrice,
      'originalPrice': originalPrice,
      'isDiscount': isDiscount ? 1 : 0,
      'taxRate': taxRate,
      'note': note,
    };
  }

  @override
  Map<String, Object?> toStashMap() {
    return {
      'productId': productId,
      'count': count,
      'singlePrice': singlePrice,
      'taxRate': taxRate,
      'note': note,
      'ingredients': ingredients
          .map((e) => e.productQuantityId == null ? null : e.toStashMap())
          .where((e) => e != null)
          .toList(),
    };
  }

  /// Create object from DB format.
  ///
  /// All property make it to optional for easy fetching metadata.
  /// See detailed in [Seller.getOrders].
  factory OrderProductObject.fromMap(
    Map<String, dynamic> data,
    Iterable<Map<String, Object?>> ingredients,
  ) {
    final id = data['id'] ?? 0;
    // null-safety to make test easy
    return OrderProductObject(
      id: id,
      productName: data['productName'] ?? '',
      catalogName: data['catalogName'] ?? '',
      count: data['count'] as int? ?? 0,
      singleCost: data['singleCost'] as num? ?? 0,
      singlePrice: data['singlePrice'] as num? ?? 0,
      originalPrice: data['originalPrice'] as num? ?? 0,
      isDiscount: data['isDiscount'] == 1,
      taxRate: data['taxRate'] as num? ?? 0.0,
      note: data['note'] as String? ?? '',
      ingredients: ingredients
          .where((Map<String, dynamic> e) => e['orderProductId'] == id)
          .map((e) => OrderIngredientObject.fromMap(e))
          .toList(),
    );
  }

  /// Create object from DB format.
  factory OrderProductObject.fromStashMap(Map<String, dynamic> data) {
    return OrderProductObject(
      productId: data['productId'],
      count: data['count'],
      singlePrice: data['singlePrice'],
      taxRate: data['taxRate'] as num? ?? 0.0,
      note: data['note'] as String? ?? '',
      ingredients: [
        for (final ing in data['ingredients'] ?? const [])
          OrderIngredientObject.fromStashMap(ing),
      ],
    );
  }
}
