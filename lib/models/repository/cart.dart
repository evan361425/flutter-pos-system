import 'package:flutter/material.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/order/order_ingredient.dart';
import 'package:possystem/models/order/order_product.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/providers/currency_provider.dart';

class Cart extends ChangeNotifier {
  static Cart instance = Cart();

  static const DEFAULT_QUANTITY_ID = '';

  List<OrderProduct> products = [];

  Map<String, String> customerSettings = {};

  bool isHistoryMode = false;

  bool get isEmpty => products.isEmpty;

  /// check if selected products are same
  bool get isSameProducts {
    final selected = this.selected;
    if (selected.isEmpty) return false;

    final firstId = selected.first.product.id;
    return selected.every((e) => e.product.id == firstId);
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
    final order = await Seller.instance.drop();
    if (order == null) return false;

    info(order.id.toString(), 'order.cart.drop');
    replaceProducts(order.parseToProduct());

    return true;
  }

  /// Get quantity of selected product in specific [ingredient]
  /// If products' ingredient have different quantity, return null
  String? getSelectedQuantityId(ProductIngredient ingredient) {
    if (!isSameProducts) return null;

    final quantites = selected.map<ProductQuantity?>(
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
    // notify when remove selected item
    OrderProduct.notifyListener(OrderProductListenerTypes.selection);
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
    final length = await Seller.instance.getStashCount();
    if (length > 4) return false;

    final data = toObject();
    info(data.totalCount.toString(), 'order.cart.stash');
    await Seller.instance.stash(data);

    clear();

    return true;
  }

  void toggleAll([bool? checked]) {
    // if empty, it will ignore to notify ingredient selector, call it manually
    if (products.isEmpty) {
      OrderProduct.notifyListener(OrderProductListenerTypes.selection);
    }
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

  void replaceProducts(List<OrderProduct> products) {
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

    selected.forEach((e) {
      final price = e.product.price * discount / 100;
      e.singlePrice = CurrencyProvider.instance.isInt ? price.round() : price;
    });
    notifyListeners();
  }

  void updateSelectedIngredient(OrderIngredient ingredient) {
    selected.forEach((e) => e.addIngredient(ingredient));
    notifyListeners();
  }

  void updateSelectedPrice(num? price) {
    if (price == null) return;

    selected.forEach((e) => e.singlePrice = price);
    notifyListeners();
  }
}
