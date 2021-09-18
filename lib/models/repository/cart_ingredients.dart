import 'package:flutter/material.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_ingredient.dart';

import 'cart.dart';

class CartIngredients extends ChangeNotifier {
  static final instance = CartIngredients._();

  late List<ProductIngredient> ingredients;

  CartIngredients._();

  bool get isEmpty => ingredients.isEmpty;

  /// Get selected quantity ID.
  ///
  /// If all using default(null quantity ID), it will return null.
  /// If selected are not same return empty string
  String? getSelectedQuantityId(String ingredientId) {
    final quantites = Cart.instance.selected
        .map((product) => product.selectedQuantity[ingredientId])
        .toList();

    assert(quantites.isNotEmpty);

    final firstId = quantites.first;
    return quantites.every((e) => e == firstId) ? firstId : '';
  }

  void select(String ingredientId, String? quantityId) {
    Cart.instance.selected.forEach((product) {
      product.selectedQuantity[ingredientId] = quantityId;
    });
    // It will change subtitle in product list
    Cart.instance.notifyListeners();
  }

  void setIngredients(Product product) {
    ingredients = product.ingredientsWithQuantity.toList();
  }
}
