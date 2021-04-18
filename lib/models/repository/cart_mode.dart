import 'package:flutter/material.dart';
import 'package:possystem/models/menu/product_ingredient_model.dart';
import 'package:possystem/models/menu/product_model.dart';
import 'package:possystem/models/menu/product_quantity_model.dart';
import 'package:possystem/models/order/order_ingredient_model.dart';
import 'package:possystem/models/order/order_product_model.dart';

class CartModel extends ChangeNotifier {
  List<OrderProductModel> products = [];

  int get totalCount {
    return products.fold(0, (value, product) => value + product.count);
  }

  num get totalPrice {
    return products.fold(0, (value, product) => value + product.price);
  }

  Iterable<OrderProductModel> get selectedProducts =>
      products.where((product) => product.isSelected);

  OrderProductModel add(ProductModel product) {
    final orderProduct = OrderProductModel(product);
    products.add(orderProduct);
    notifyListeners();

    return orderProduct;
  }

  void toggleAll([bool checked]) {
    products.forEach((product) => product.toggleSelected(checked));
    // notifyListeners();
  }

  Iterable<OrderProductModel> get selectedSameProduct {
    final products = selectedProducts;
    if (products.isEmpty) return null;

    final firstId = products.first.product.id;
    return products.every((e) => e.product.id == firstId) ? products : null;
  }

  /// Get quantity of selected product in specific [ingredient]
  /// If products' ingredient have different quantity, return null
  String getSelectedQuantityId(ProductIngredientModel ingredient) {
    final products = selectedSameProduct;
    if (products.isEmpty) return null;

    final quantites = products.map<ProductQuantityModel>((product) {
      return product.getIngredientOf(ingredient.id)?.quantity;
    });

    final firstId = quantites.first?.id;
    // All selected product have same quantity
    if (quantites.every((e) => e?.id == firstId)) {
      // if using default, it will be null
      return firstId == null ? DEFAULT_QUANTITY_ID : quantites.first.id;
    } else {
      return null;
    }
  }

  // ACTIONS

  void removeSelected() {
    products.removeWhere((e) => e.isSelected);
    notifyListeners();
  }

  void discountSelected(int discount) {
    if (discount == null) return;

    selectedProducts.forEach((e) {
      e.singlePrice = e.product.price * discount / 100;
    });
    notifyListeners();
  }

  void updateSelectedPrice(num price) {
    if (price == null) return;

    selectedProducts.forEach((e) {
      e.singlePrice = price;
    });
    notifyListeners();
  }

  void updateSelectedCount(int count) {
    if (count == null) return;

    selectedProducts.forEach((e) {
      e.count = count;
    });
    notifyListeners();
  }

  void updateSelectedIngredient(OrderIngredientModel ingredient) {
    selectedProducts.forEach((e) {
      e.addIngredient(ingredient);
    });
    notifyListeners();
  }

  void removeSelectedIngredient(ProductIngredientModel ingredient) {
    selectedProducts.forEach((e) {
      e.removeIngredient(ingredient);
    });
    notifyListeners();
  }

  // CONST

  static const DEFAULT_QUANTITY_ID = '';
}
