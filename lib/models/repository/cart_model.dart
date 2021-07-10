import 'package:flutter/material.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/menu/product_ingredient_model.dart';
import 'package:possystem/models/menu/product_model.dart';
import 'package:possystem/models/menu/product_quantity_model.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/order/order_ingredient_model.dart';
import 'package:possystem/models/order/order_product_model.dart';
import 'package:possystem/models/repository/order_repo.dart';
import 'package:possystem/models/repository/stock_model.dart';

class CartModel extends ChangeNotifier {
  static CartModel instance = CartModel();

  static const DEFAULT_QUANTITY_ID = '';

  List<OrderProductModel> products = [];

  bool isHistoryMode = false;

  bool get isEmpty => products.isEmpty;

  /// check if selected products are same
  bool get isSameProducts {
    final selected = this.selected;
    if (selected.isEmpty) return false;

    final firstId = selected.first.product.id;
    return selected.every((e) => e.product.id == firstId);
  }

  Iterable<OrderProductModel> get selected =>
      products.where((product) => product.isSelected);

  int get totalCount {
    return products.fold(0, (value, product) => value + product.count);
  }

  num get totalPrice {
    return products.fold(0, (value, product) => value + product.price);
  }

  OrderProductModel add(ProductModel product) {
    final orderProduct = OrderProductModel(product, isSelected: true);

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

  Future<bool> drop() async {
    final order = await OrderRepo.instance.drop();
    if (order == null) return false;

    info(order.id.toString(), 'cart.order.drop');
    replaceProducts(order.parseToProduct());

    return true;
  }

  /// Get quantity of selected product in specific [ingredient]
  /// If products' ingredient have different quantity, return null
  String? getSelectedQuantityId(ProductIngredientModel ingredient) {
    if (!isSameProducts) return null;

    final quantites = selected.map<ProductQuantityModel?>(
        (product) => product.getIngredient(ingredient.id)?.quantity);

    final firstId = quantites.first?.id;
    // All selected product have same quantity
    if (quantites.every((e) => e?.id == firstId)) {
      // if using default, it will be null
      return firstId ?? DEFAULT_QUANTITY_ID;
    } else {
      return null;
    }
  }

  void leaveHistoryMode() {
    isHistoryMode = false;
    clear();
  }

  Future<void> paid(num? paid) async {
    if (totalCount == 0) {
      // TODO: delete order if in history mode
      isHistoryMode ? leaveHistoryMode() : clear();
      return;
    }

    final price = totalPrice;
    paid ??= price;
    if (paid < price) throw 'too low';

    // if history mode update data
    if (isHistoryMode) {
      final oldData = await OrderRepo.instance.pop();
      final data = toObject(paid: paid, object: oldData);

      info(data.id.toString(), 'cart.order.update');
      await OrderRepo.instance.update(data);
      await StockModel.instance.order(data, oldData: oldData);

      leaveHistoryMode();
    } else {
      final data = toObject(paid: paid);

      info(data.totalCount.toString(), 'cart.order.push');
      await OrderRepo.instance.push(data);
      await StockModel.instance.order(data);

      clear();
    }
  }

  Future<bool> popHistory() async {
    final order = await OrderRepo.instance.pop();
    if (order == null) return false;

    info(order.id.toString(), 'cart.order.pop');
    replaceProducts(order.parseToProduct());

    isHistoryMode = true;

    return true;
  }

  void removeSelected() {
    products.removeWhere((e) => e.isSelected);
    notifyListeners();
  }

  void removeSelectedIngredient(String id) {
    selected.forEach((e) => e.removeIngredient(id));
    notifyListeners();
  }

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

  void toggleAll([bool? checked]) {
    products.forEach((product) => product.toggleSelected(checked));
    notifyListeners();
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

  void replaceProducts(List<OrderProductModel> products) {
    this.products = products;
    notifyListeners();
  }

  void updateSelectedCount(int? count) {
    if (count == null) return;

    selected.forEach((e) => e.count = count);
    notifyListeners();
  }

  void updateSelectedDiscount(int? discount) {
    if (discount == null) return;

    selected.forEach((e) => e.singlePrice = e.product.price * discount / 100);
    notifyListeners();
  }

  void updateSelectedIngredient(OrderIngredientModel ingredient) {
    selected.forEach((e) => e.addIngredient(ingredient));
    notifyListeners();
  }

  void updateSelectedPrice(num? price) {
    if (price == null) return;

    selected.forEach((e) => e.singlePrice = price);
    notifyListeners();
  }
}
