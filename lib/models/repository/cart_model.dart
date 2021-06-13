import 'package:flutter/material.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/repository/order_repo.dart';
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

  /// get selected products if all products are same
  Iterable<OrderProductModel?>? get selectedSameProduct {
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
    final length = await OrderRepo.instance.getStashCount();
    if (length > 4) return false;

    final data = toObject();
    info(data.totalCount.toString(), 'cart.order.stash');

    await OrderRepo.instance.stash(data);
    clear();

    return true;
  }

  Future<bool> drop() async {
    final order = await OrderRepo.instance.drop();
    if (order == null) return false;

    info(order.id.toString(), 'cart.order.drop');

    updateProductions(order.parseToProduct());
    return true;
  }

  Future<void> paid(num? paid) async {
    final price = totalPrice;
    paid ??= price;
    if (paid < price) throw 'too low';

    // if history mode update data
    if (isHistoryMode) {
      final oldData = await OrderRepo.instance.pop();
      final data = toObject(paid: paid, object: oldData);

      info(data.id.toString(), 'cart.order.update');

      // must follow the order, avoid missing data
      await OrderRepo.instance.update(data);
      await StockModel.instance.order(data, oldData: oldData);
      leaveHistoryMode();
    } else {
      final data = toObject(paid: paid);

      info(data.totalCount.toString(), 'cart.order.push');

      // must follow the order, avoid missing data
      await OrderRepo.instance.push(data);
      await StockModel.instance.order(data);
      clear();
    }
  }

  Future<bool> popHistory() async {
    final order = await OrderRepo.instance.pop();
    if (order == null) return false;

    info(order.id.toString(), 'cart.order.pop');

    updateProductions(order.parseToProduct());
    isHistoryMode = true;

    return true;
  }

  void leaveHistoryMode() {
    isHistoryMode = false;
    clear();
  }

  OrderObject toObject({num? paid, OrderObject? object}) {
    return OrderObject(
      id: object?.id,
      paid: paid,
      createdAt: object?.createdAt,
      totalPrice: totalPrice,
      totalCount: totalCount,
      products: products.map<OrderProductObject>((e) => e.toObject()),
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
  String? getSelectedQuantityId(ProductIngredientModel? ingredient) {
    final products = selectedSameProduct!;
    if (products.isEmpty) return null;

    final quantites = products.map<ProductQuantityModel?>((product) {
      return product!.getIngredientOf(ingredient!.id)?.quantity;
    });

    final firstId = quantites.first?.id;
    // All selected product have same quantity
    if (quantites.every((e) => e?.id == firstId)) {
      // if using default, it will be null
      return firstId == null ? DEFAULT_QUANTITY_ID : quantites.first!.id;
    } else {
      return null;
    }
  }

  void removeSelected() {
    products.removeWhere((e) => e.isSelected);
    notifyListeners();
  }

  void removeSelectedIngredient(String id) {
    selectedProducts.forEach((e) {
      e.removeIngredient(id);
    });
    notifyListeners();
  }

  void toggleAll([bool? checked]) {
    products.forEach((product) => product.toggleSelected(checked));
    notifyListeners();
  }

  void updateProductions(List<OrderProductModel> products) {
    this.products = products;
    notifyListeners();
  }

  void updateSelectedCount(int? count) {
    if (count == null) return;

    selectedProducts.forEach((e) {
      e.count = count;
    });
    notifyListeners();
  }

  void updateSelectedDiscount(int? discount) {
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

  void updateSelectedPrice(num? price) {
    if (price == null) return;

    selectedProducts.forEach((e) {
      e.singlePrice = price;
    });
    notifyListeners();
  }
}
