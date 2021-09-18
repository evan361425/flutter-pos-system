import 'package:flutter/material.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/order/order_product.dart';
import 'package:possystem/providers/currency_provider.dart';

import 'cart_ingredients.dart';
import 'cashier.dart';
import 'seller.dart';
import 'stock.dart';

class Cart extends ChangeNotifier {
  static Cart instance = Cart();

  List<OrderProduct> products = [];

  Map<String, String> customerSettings = {};

  bool isHistoryMode = false;

  bool get isEmpty => products.isEmpty;

  /// check if selected products are same
  bool get isSameProducts {
    final selected = this.selected;
    if (selected.isEmpty) return false;

    final firstId = selected.first.id;
    return selected.every((e) => e.id == firstId);
  }

  Iterable<OrderProduct> get selected =>
      products.where((product) => product.isSelected);

  int get totalCount {
    return products.fold(0, (value, product) => value + product.count);
  }

  num get totalPrice {
    return products.fold(0, (value, product) => value + product.price);
  }

  OrderProduct add(Product product) {
    final orderProduct = OrderProduct(product, isSelected: true);

    products.add(orderProduct);
    notifyListeners();
    // If unselect all products and add new product
    // this can help notify ingredients
    CartIngredients.instance.notifyListeners();

    return orderProduct;
  }

  void clear() {
    products.clear();
    customerSettings.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    products.clear();
    customerSettings.clear();
    super.dispose();
  }

  Future<bool> drop() async {
    final order = await Seller.instance.drop();
    if (order == null) return false;

    info(order.id.toString(), 'order.cart.drop');
    replaceProducts(order.parseToProduct());

    return true;
  }

  void leaveHistoryMode() {
    isHistoryMode = false;
    clear();
  }

  Future<void> paid(num? paid) async {
    if (totalCount == 0) {
      isHistoryMode ? leaveHistoryMode() : clear();
      return;
    }

    final price = totalPrice;
    paid ??= price;
    if (paid < price) throw 'too low';

    // if history mode update data
    if (isHistoryMode) {
      final oldData = await Seller.instance.pop();
      final data = toObject(paid: paid, object: oldData);

      info(data.id.toString(), 'order.cart.update');
      await Seller.instance.update(data);
      await Stock.instance.order(data, oldData: oldData);
      await Cashier.instance.paid(paid, data.totalPrice, oldData?.totalPrice);

      leaveHistoryMode();
    } else {
      final data = toObject(paid: paid);

      info(data.totalCount.toString(), 'order.cart.push');
      await Seller.instance.push(data);
      await Stock.instance.order(data);
      await Cashier.instance.paid(paid, data.totalPrice);

      clear();
    }
  }

  Future<bool> popHistory() async {
    final order = await Seller.instance.pop();
    if (order == null) return false;

    info(order.id.toString(), 'order.cart.pop');
    replaceProducts(order.parseToProduct());

    isHistoryMode = true;

    return true;
  }

  void removeSelected() {
    products.removeWhere((e) => e.isSelected);
    notifyListeners();
  }

  void replaceProducts(List<OrderProduct> products) {
    this.products = products;
    notifyListeners();
  }

  /// If not stashable return false
  /// Rate limit = 5
  Future<bool> stash() async {
    if (isEmpty) return true;

    // disallow before stash, so need minus 1
    final length = await Seller.instance.getStashCount();
    if (length > 4) return false;

    final data = toObject();
    info(data.totalCount.toString(), 'order.cart.stash');
    await Seller.instance.stash(data);

    clear();

    return true;
  }

  void toggleAll(bool? checked, {String? except}) {
    // except only acceptable when specify checked
    assert(checked != null || except == null);

    products.forEach((product) =>
        product.toggleSelected(product.id == except ? !checked! : checked));
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

  void updateSelectedCount(int? count) {
    if (count == null) return;

    selected.forEach((e) => e.count = count);
    notifyListeners();
  }

  void updateSelectedDiscount(int? discount) {
    if (discount == null) return;

    selected.forEach((e) {
      final price = e.product.price * discount / 100;
      e.singlePrice = CurrencyProvider.instance.isInt ? price.round() : price;
    });
    notifyListeners();
  }

  void updateSelectedPrice(num? price) {
    if (price == null) return;

    selected.forEach((e) => e.singlePrice = price);
    notifyListeners();
  }
}
