import 'package:flutter/material.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/models/repository/cart_ingredients.dart';
import 'package:possystem/translator.dart';

class OrderProduct extends ChangeNotifier {
  final Product product;

  final Map<String, String?> selectedQuantity;

  bool isSelected;

  num singlePrice;

  int count;

  OrderProduct(
    this.product, {
    this.count = 1,
    num? singlePrice,
    this.isSelected = false,
    Map<String, String?>? selectedQuantity,
  })  : singlePrice = singlePrice ?? product.price,
        selectedQuantity = selectedQuantity ??
            {for (final ingredient in product.items) ingredient.id: null};

  void rebind() {
    // check missing
    for (final ingredient in product.items) {
      if (!selectedQuantity.containsKey(ingredient.id)) {
        selectedQuantity[ingredient.id] = null;
      }
    }

    // check not exist
    selectedQuantity.entries.toList().forEach((entry) {
      final ingredient = product.getItem(entry.key);
      if (ingredient == null) {
        selectedQuantity.remove(entry.key);
      } else if (entry.value != null &&
          ingredient.getItem(entry.value!) == null) {
        selectedQuantity[entry.key] = null;
      }
    });
  }

  String get id => product.id;

  bool get isEmpty => selectedQuantity.values.every((e) => e == null);

  String get name => product.name;

  num get price => count * singlePrice;

  Iterable<String> getIngredientNames({bool onlyQuantitied = true}) {
    final entries = onlyQuantitied
        ? selectedQuantity.entries.where((entry) => entry.value != null)
        : selectedQuantity.entries;

    return entries.map<String>((entry) {
      final ingredient = product.getItem(entry.key)!;
      if (entry.value == null) {
        return S.orderProductIngredientDefaultName(ingredient.name);
      }

      final quantity = ingredient.getItem(entry.value!)!;
      return S.orderProductIngredientName(ingredient.name, quantity.name);
    });
  }

  num getQuantityPrice(String ingredientId, String? quantityId) {
    if (quantityId == null) return 0;

    return product
            .getItem(ingredientId)
            ?.getItem(quantityId)
            ?.additionalPrice ??
        0;
  }

  void increment() {
    count += 1;
    notifyListeners();
    Cart.instance.notifyListeners();
  }

  void selectQuantity(String ingredientId, [String? quantityId]) {
    assert(selectedQuantity.containsKey(ingredientId));

    final oldQuantity = selectedQuantity[ingredientId];
    singlePrice -= getQuantityPrice(ingredientId, oldQuantity);

    selectedQuantity[ingredientId] = quantityId;
    singlePrice += getQuantityPrice(ingredientId, quantityId);
  }

  /// if [checked] is defferent with current state
  /// return false else true
  bool toggleSelected([bool? checked]) {
    checked ??= !isSelected;
    final changed = isSelected != checked;

    if (changed) {
      isSelected = checked;
      notifyListeners();
      // selected changed, need change ingredients
      CartIngredients.instance.notifyListeners();
    }

    return changed;
  }

  OrderProductObject toObject() {
    final ingredients = <String, OrderIngredientObject>{
      for (var entry in selectedQuantity.entries)
        entry.key: OrderIngredientObject.fromModel(
          product.getItem(entry.key)!,
          entry.value,
        )
    };
    final originalPrice = product.price;

    return OrderProductObject(
      singlePrice: singlePrice,
      count: count,
      productId: product.id,
      productName: product.name,
      originalPrice: originalPrice,
      isDiscount: singlePrice < originalPrice,
      ingredients: ingredients,
    );
  }
}
