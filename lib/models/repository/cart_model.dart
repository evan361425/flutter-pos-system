import 'package:flutter/material.dart';
import 'package:possystem/models/histories/order_history.dart';
import 'package:possystem/models/menu/product_ingredient_model.dart';
import 'package:possystem/models/menu/product_model.dart';
import 'package:possystem/models/menu/product_quantity_model.dart';
import 'package:possystem/models/order/order_ingredient_model.dart';
import 'package:possystem/models/order/order_product_model.dart';

class CartModel extends ChangeNotifier {
  static final CartModel _instance = CartModel._constructor();

  static const DEFAULT_QUANTITY_ID = '';

  static CartModel get instance => _instance;

  List<OrderProductModel> products = [];

  CartModel._constructor();

  Iterable<OrderProductModel> get selectedProducts =>
      products.where((product) => product.isSelected);

  Iterable<OrderProductModel> get selectedSameProduct {
    final products = selectedProducts;
    if (products.isEmpty) return null;

    final firstId = products.first.product.id;
    return products.every((e) => e.product.id == firstId) ? products : null;
  }

  int get totalCount {
    return products.fold(0, (value, product) => value + product.count);
  }

  num get totalPrice {
    return products.fold(0, (value, product) => value + product.price);
  }

  OrderProductModel add(ProductModel product) {
    final orderProduct = OrderProductModel(product);
    products.add(orderProduct);
    notifyListeners();

    return orderProduct;
  }

  void clear() {
    products.clear();
  }

  @override
  void dispose() {
    clear();
    super.dispose();
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

  String paid(num paid) {
    final price = totalPrice;
    paid ??= price;

    if (paid < price) return 'too low';

    OrderHistory.instance.add({
      'paid': paid,
      'totalPrice': price,
      'totalCount': totalCount,
      'products': products.map((e) => e.toMap()).toList(),
    });

    clear();
    notifyListeners();

    return null;
  }

  void removeSelected() {
    products.removeWhere((e) => e.isSelected);
    notifyListeners();
  }

  void removeSelectedIngredient(ProductIngredientModel ingredient) {
    selectedProducts.forEach((e) {
      e.removeIngredient(ingredient);
    });
    notifyListeners();
  }

  void toggleAll([bool checked]) {
    products.forEach((product) => product.toggleSelected(checked));
    notifyListeners();
  }

  void updateSelectedCount(int count) {
    if (count == null) return;

    selectedProducts.forEach((e) {
      e.count = count;
    });
    notifyListeners();
  }

  void updateSelectedDiscount(int discount) {
    if (discount == null) return;

    selectedProducts.forEach((e) {
      e.singlePrice = e.product.price * discount / 100;
    });
    notifyListeners();
  }

  void updateSelectedIngredient(OrderIngredientModel ingredient) {
    selectedProducts.forEach((e) {
      e.addIngredient(ingredient);
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
}
