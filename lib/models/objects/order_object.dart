import 'dart:convert';
import 'dart:math';

import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/objects/order_attribute_object.dart';
import 'package:possystem/models/order/cart_product.dart';
import 'package:possystem/models/order/order_attribute_option.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/seller.dart';

/// Order in object mode, helps I/O in DB.
class OrderObject extends _Object {
  /// ID of database row
  final int? id;

  /// Money paid from customer.
  final num paid;

  /// The cost of order.
  final num cost;

  /// The price of order, all products' price and order attribute's price.
  final num price;

  /// Note for the order.
  final String note;

  /// The count of products.
  final int productsCount;

  /// All products' price.
  final num productsPrice;

  /// Attributes details of the order.
  final List<OrderSelectedAttributeObject> attributes;

  /// All product details.
  final List<OrderProductObject> products;

  /// Order created time, important property to sort.
  final DateTime createdAt;

  /// Should not use the default value which only for help on test.
  const OrderObject({
    this.id,
    this.paid = 0,
    this.cost = 0,
    this.price = 0,
    this.note = '',
    this.productsCount = 0,
    this.productsPrice = 0,
    this.attributes = const [],
    this.products = const [],
    required this.createdAt,
  });

  /// Profit, [price] minus [cost].
  num get profit => price - cost;

  /// Price that cause by order attributes, [price] minus [productsPrice].
  num get attributesPrice => price - productsPrice;

  /// Given change, [paid] minus [price].
  num get change => paid - price;

  /// Get [products] as [CartProduct].
  ///
  /// Help to restore from stash.
  Iterable<CartProduct> get productModels sync* {
    for (final object in products) {
      final product = Menu.instance.getProduct(object.productId);

      if (product == null) continue;

      yield CartProduct(
        product,
        count: object.count,
        singlePrice: object.singlePrice,
        quantities: {
          for (final item in object.ingredients)
            if (item.productQuantityId != null) item.productIngredientId: item.productQuantityId!
        },
      );
    }
  }

  /// Get [attributes] as map.
  ///
  /// Help to restore from stash.
  Map<String, String> get selectedAttributes => {
        for (final attr in attributes) attr.attributeId: attr.optionId,
      };

  /// Update the amounts of stock by the ordered ingredients.
  void applyToStock(Map<String, num> amounts, {required bool add}) {
    for (final product in products) {
      for (final ing in product.ingredients) {
        final val = add ? ing.amount : -ing.amount;
        amounts[ing.ingredientId] = (amounts[ing.ingredientId] ?? 0) + val;
      }
    }
  }

  @override
  Map<String, Object?> toMap() {
    return {
      'paid': paid,
      'price': price,
      'cost': cost,
      'revenue': profit,
      'note': note,
      'productsPrice': productsPrice,
      'productsCount': productsCount,
      'attributesPrice': attributesPrice,
      'createdAt': Util.toUTC(now: createdAt),
    };
  }

  @override
  Map<String, Object?> toStashMap() {
    return {
      'note': note,
      'encodedProducts': jsonEncode(products.map((e) => e.toStashMap()).toList()),
      'encodedAttributes': jsonEncode(attributes.map((e) => e.toStashMap()).toList()),
      'createdAt': Util.toUTC(now: createdAt),
    };
  }

  /// Create object from DB format.
  factory OrderObject.fromMap(
    Map<String, Object?> order,
    Iterable<Map<String, Object?>> products, [
    List<Map<String, Object?>> ingredients = const [],
    List<Map<String, Object?>> attributes = const [],
  ]) {
    // null-safety to make test easy
    return OrderObject(
      id: order['id'] as int? ?? 0,
      paid: order['paid'] as num? ?? 0,
      cost: order['cost'] as num? ?? 0,
      price: order['price'] as num? ?? 0,
      note: order['note'] as String? ?? '',
      productsCount: order['productsCount'] as int? ?? 0,
      productsPrice: order['productsPrice'] as num? ?? 0,
      products: [
        for (Map<String, dynamic> product in products) OrderProductObject.fromMap(product, ingredients),
      ],
      attributes: [
        for (Map<String, dynamic> attr in attributes) OrderSelectedAttributeObject.fromMap(attr),
      ],
      createdAt: Util.fromUTC(order['createdAt'] as int? ?? 0),
    );
  }

  /// Create object from DB format.
  factory OrderObject.fromStashMap(Map<String, Object?> data) {
    final products = _safeParseList(data['encodedProducts'] as String?);
    final attributes = _safeParseList(data['encodedAttributes'] as String?);

    return OrderObject(
      id: data['id'] as int?,
      note: data['note'] as String? ?? '',
      attributes: attributes.map((e) => OrderSelectedAttributeObject.fromStashMap(e)).toList(),
      products: products.map((e) => OrderProductObject.fromStashMap(e)).toList(),
      createdAt: Util.fromUTC(data['createdAt'] as int? ?? 0),
    );
  }
}

/// Single product set of the order in object mode, helps I/O in DB.
class OrderProductObject extends _Object {
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
    this.ingredients = const [],
  });

  /// Total price of the products, after updated by discount.
  num get totalPrice => count * singlePrice;

  /// Total cost of the products, after updated by ingredient.
  num get totalCost => count * singleCost;

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
    };
  }

  @override
  Map<String, Object?> toStashMap() {
    return {
      'productId': productId,
      'count': count,
      'singlePrice': singlePrice,
      'ingredients':
          ingredients.map((e) => e.productQuantityId == null ? null : e.toStashMap()).where((e) => e != null).toList(),
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
      ingredients: [
        for (final ing in data['ingredients']) OrderIngredientObject.fromStashMap(ing),
      ],
    );
  }
}

/// Product single ingredient details in object mode, helps I/O in DB.
class OrderIngredientObject extends _Object {
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

/// Attribute helps get more info on the order.
class OrderSelectedAttributeObject extends _Object {
  /// ID of database row
  final int id;

  /// The attribute name, for example: age.
  final String name;

  /// The attribute's option name, for example: bellow 18.
  final String optionName;

  /// The attribute mode which help to identify this attribute usage.
  final OrderAttributeMode mode;

  /// The mode value, for example decrease order price 10 dollars.
  final num? modeValue;

  /// ID of attribute, help restore data from stashed.
  final String attributeId;

  /// ID of attribute's option, help restore data from stashed.
  final String optionId;

  /// Should not use the default value which only for help on test.
  const OrderSelectedAttributeObject({
    this.id = 0,
    this.name = '',
    this.optionName = '',
    this.mode = OrderAttributeMode.statOnly,
    this.modeValue,
    this.attributeId = '',
    this.optionId = '',
  });

  @override
  Map<String, Object?> toMap() {
    return {
      'name': name,
      'optionName': optionName,
      'mode': mode.index,
      'modeValue': modeValue,
    };
  }

  @override
  Map<String, Object?> toStashMap() {
    return {
      'attributeId': attributeId,
      'optionId': optionId,
    };
  }

  /// Create object from map.
  factory OrderSelectedAttributeObject.fromMap(Map<String, dynamic> data) {
    final modeIndex = min(
      data['mode'] as int? ?? 0,
      OrderAttributeMode.values.length - 1,
    );
    final mode = OrderAttributeMode.values[max(modeIndex, 0)];

    // null-safety to make test easy
    return OrderSelectedAttributeObject(
      id: data['id'] as int? ?? 0,
      name: data['name'] as String? ?? '',
      optionName: data['optionName'] as String? ?? '',
      mode: mode,
      modeValue: data['modeValue'],
    );
  }

  /// Create object from DB format.
  factory OrderSelectedAttributeObject.fromStashMap(Map<String, dynamic> data) {
    return OrderSelectedAttributeObject(
      attributeId: data['attributeId'],
      optionId: data['optionId'],
    );
  }

  /// Create object from model.
  factory OrderSelectedAttributeObject.fromModel(OrderAttributeOption option) {
    return OrderSelectedAttributeObject(
      name: option.attribute.name,
      optionName: option.name,
      mode: option.mode,
      modeValue: option.modeValue,
      attributeId: option.attribute.id,
      optionId: option.id,
    );
  }
}

List<dynamic> _safeParseList(String? source) {
  try {
    return jsonDecode(source ?? '');
  } catch (e) {
    return const [];
  }
}

/// Base class for all order object.
abstract class _Object {
  /// Object can dump in two format, history and stash.
  const _Object();

  /// To map format for DB I/O.
  Map<String, Object?> toMap();

  /// To map format for stash and drop.
  Map<String, Object?> toStashMap();
}
