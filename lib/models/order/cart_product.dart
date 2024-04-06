import 'package:flutter/material.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/objects/order_object.dart';

/// Product in the cart.
///
/// Will be notify when selected, increment and quantity changed.
class CartProduct extends ChangeNotifier {
  /// Menu product.
  final Product product;

  /// Is this product being selected in cart?
  bool isSelected;

  num _singlePrice;

  int _count;

  /// Ingredient and quantity pairs.
  ///
  /// Keys are ingredient and values are quantities.
  final Map<String, String> _quantities;

  /// [product] will set the default [singlePrice] and [quantities] is default
  /// to empty map.
  CartProduct(
    this.product, {
    int count = 1,
    num? singlePrice,
    this.isSelected = false,
    Map<String, String>? quantities,
  })  : _singlePrice = singlePrice ?? product.price,
        _count = count,
        _quantities = quantities ?? <String, String>{};

  /// product's ID
  String get id => product.id;

  /// product's name
  String get name => product.name;

  /// The cost of single product.
  num get cost => quantities.fold<num>(product.cost, (v, q) => v + (q.additionalCost));

  /// Total price which is single price times the count.
  num get totalPrice => _count * _singlePrice;

  /// Total cost which is single cost times the count.
  num get totalCost => _count * cost;

  /// Get all ingredients that has selected quantity.
  Iterable<ProductQuantity> get quantities => _quantities.entries
      .map((e) {
        return product.getItem(e.key)?.getItem(e.value);
      })
      .where((e) => e != null)
      .cast<ProductQuantity>();

  /// The price of the product, it may be affected by quantity of ingredients.
  set singlePrice(num other) {
    if (other != _singlePrice) {
      _singlePrice = other;
      notifyListeners();
    }
  }

  /// The count of the this product.
  int get count => _count;
  set count(int other) {
    if (other != _count) {
      _count = other;
      notifyListeners();
    }
  }

  /// Get quantity of specific ingredient.
  String? getQuantityId(String ingredientId) {
    return _quantities[ingredientId];
  }

  /// Get specific ingredient and quantity additional price.
  num getQuantityPrice(String ingredientId, String? quantityId) {
    if (quantityId == null) return 0;

    return product.getItem(ingredientId)?.getItem(quantityId)?.additionalPrice ?? 0;
  }

  /// Selected the quantity from cart and affect the price.
  void selectQuantity(String ingredientId, [String? quantityId]) {
    final old = _quantities[ingredientId];
    _singlePrice -= getQuantityPrice(ingredientId, old);

    if (quantityId == null) {
      _quantities.remove(ingredientId);
    } else {
      _quantities[ingredientId] = quantityId;
      _singlePrice += getQuantityPrice(ingredientId, quantityId);
    }

    notifyListeners();
  }

  /// Increase product count.
  void increment() {
    _count += 1;

    notifyListeners();
  }

  /// Toggle selected state.
  ///
  /// If [checked] is different with current state return false else true.
  bool toggleSelected([bool? checked]) {
    checked ??= !isSelected;
    final changed = isSelected != checked;

    if (changed) {
      isSelected = checked;
      notifyListeners();
    }

    return changed;
  }

  /// Rebind the product from menu which is our source of truth.
  ///
  /// Enter the order page again the source might changed from other pages.
  void rebind() {
    // check missing
    for (final entry in _quantities.entries.toList()) {
      final item = product.getItem(entry.key);
      if (item?.hasItem(entry.value) != true) {
        _quantities.remove(entry.key);
      }
    }
  }

  /// Convert to [OrderProductObject].
  OrderProductObject toObject() {
    return OrderProductObject(
      productId: product.id,
      productName: product.name,
      catalogName: product.catalog.name,
      count: _count,
      singleCost: cost,
      singlePrice: _singlePrice,
      originalPrice: product.price,
      isDiscount: _singlePrice < product.price,
      ingredients: product.items.map((e) => OrderIngredientObject.fromModel(e, getQuantityId(e.id))).toList(),
    );
  }
}
