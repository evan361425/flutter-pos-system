import 'package:flutter/material.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_ingredient.dart';

import 'cart.dart';

class CartIngredients extends ChangeNotifier {
  static final instance = CartIngredients._();

  late List<ProductIngredient> ingredients;

  late ProductIngredient? selected;

  String productId = '';

  CartIngredients._();

  /// Get selected quantity ID.
  ///
  /// If all using default(null quantity ID), it will return null.
  /// If selected are not same return empty string
  String? getSelectedQuantityId() {
    final quantites = Cart.instance.selected
        .map((product) => product.selectedQuantity[selected!.id])
        .toList();

    assert(quantites.isNotEmpty);

    final firstId = quantites.first;
    return quantites.every((e) => e == firstId) ? firstId : '';
  }

  void selectIngredient(ProductIngredient ingredient) {
    selected = ingredient;
  }

  void selectQuantity(String? quantityId) {
    for (var product in Cart.instance.selected) {
      product.selectQuantity(selected!.id, quantityId);
    }
    // It will change price on metadata
    Cart.instance.notifyListeners();
  }

  void setIngredients(Product product) {
    if (productId != product.id) {
      productId = product.id;
      ingredients = product.items.toList();

      if (ingredients.isNotEmpty) {
        selected = ingredients.first;
      }
    }
  }
}
