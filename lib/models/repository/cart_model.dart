import 'package:flutter/material.dart';
import 'package:possystem/models/histories/order_history.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/menu/product_ingredient_model.dart';
import 'package:possystem/models/menu/product_model.dart';
import 'package:possystem/models/menu/product_quantity_model.dart';
import 'package:possystem/models/order/order_ingredient_model.dart';
import 'package:possystem/models/order/order_product_model.dart';
import 'package:possystem/models/repository/stock_model.dart';

class CartModel extends ChangeNotifier {
  static final CartModel _instance = CartModel._constructor();

  static const DEFAULT_QUANTITY_ID = '';

  static CartModel get instance => _instance;

  List<OrderProductModel> products = [];
  bool isHistoryMode = false;

  CartModel._constructor();

  Iterable<OrderProductModel> get selectedProducts =>
      products.where((product) => product.isSelected);

  Iterable<OrderProductModel> get selectedSameProduct {
    final products = selectedProducts;
    if (products.isEmpty) return null;

    final firstId = products.first.product.id;
    return products.every((e) => e.product.id == firstId) ? products : null;
  }

  bool get isEmpty => products.isEmpty;

  /// If not stashable return false
  /// Rate limit = 5
  Future<bool> stash() async {
    if (isEmpty) return true;

    // disallow before stash, so need minus 1
    if (await OrderHistory.instance.getStashLength() > 4) return false;

    OrderHistory.instance.stash(output());
    clear();
    return true;
  }

  Future<bool> popStash() async {
    final order = await OrderHistory.instance.popStash();
    if (order == null) return false;

    updateProductions(order.parseToProduct());
    return true;
  }

  Future<void> paid(num paid) async {
    final price = totalPrice;
    paid ??= price;
    if (paid < price) throw 'too low';

    // if history mode, remove last order info
    if (isHistoryMode) {
      await OrderHistory.instance.pop(true);
    }

    final data = output(paid);

    OrderHistory.instance.push(data);
    StockModel.instance.order(data);
    leaveHistoryMode();
  }

  Future<bool> popHistory() async {
    final order = await OrderHistory.instance.pop();
    if (order == null) return false;

    updateProductions(order.parseToProduct());
    isHistoryMode = true;
    return true;
  }

  void leaveHistoryMode() {
    isHistoryMode = false;
    clear();
  }

  OrderObject output([num paid]) {
    return OrderObject(
      paid: paid,
      totalPrice: totalPrice,
      totalCount: totalCount,
      products: products.map<OrderProductObject>((e) => e.toMap()),
    );
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
    notifyListeners();
  }

  @override
  void dispose() {
    products.clear();
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

  void updateProductions(List<OrderProductModel> products) {
    this.products = products;
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
