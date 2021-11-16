import 'package:flutter/material.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product_quantity.dart';

import 'cart.dart';

class CartIngredients extends ChangeNotifier {
  static final instance = CartIngredients._();

  late List<ProductIngredient> _ingredients;

  ProductIngredient? _selected;

  String _productId = '';

  CartIngredients._();

  bool get isEmpty => _ingredients.isEmpty;

  List<ProductIngredient> get itemList => _ingredients;

  Iterable<ProductQuantity> get quantityList => _selected!.items;

  num get selectedAmount => _selected!.amount;

  String get selectedId => _selected!.id;

  /// Get selected quantity ID.
  ///
  /// If all using default(null quantity ID), it will return null.
  /// If selected are not same return empty string
  String? get selectedQuantityId {
    final quantites = Cart.instance.selected
        .map((product) => product.selectedQuantity[selectedId])
        .toList();

    final firstId = quantites.first;
    return quantites.every((e) => e == firstId) ? firstId : '';
  }

  void selectIngredient(ProductIngredient ingredient) {
    _selected = ingredient;
  }

  void selectIngredientBy(Product product) {
    if (_productId != product.id) {
      _productId = product.id;
      _ingredients = product.items.toList();

      if (_ingredients.isNotEmpty) {
        _selected = _ingredients.first;
      }
    }
  }

  void selectQuantity(String? quantityId) {
    for (var product in Cart.instance.selected) {
      product.selectQuantity(selectedId, quantityId);
    }
    // It will change price on metadata
    Cart.instance.notifyListeners();
  }
}
