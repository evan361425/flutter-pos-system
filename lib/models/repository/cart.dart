import 'package:flutter/material.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/customer/customer_setting_option.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/order/order_product.dart';
import 'package:possystem/models/repository/cart_ingredients.dart';
import 'package:possystem/models/repository/customer_settings.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/providers/currency_provider.dart';

import 'cashier.dart';
import 'seller.dart';
import 'stock.dart';

class Cart extends ChangeNotifier {
  static Cart instance = Cart();

  final List<OrderProduct> products = [];

  final Map<String, String> customerSettings = {};

  bool isHistoryMode = false;

  bool get isEmpty => products.isEmpty;

  /// check if selected products are same
  bool get isSameProducts {
    final selected = this.selected;
    if (selected.isEmpty) return false;

    final firstId = selected.first.id;
    return selected.every((e) => e.id == firstId);
  }

  num get productsPrice {
    return products.fold(0, (value, product) => value + product.price);
  }

  Iterable<OrderProduct> get selected =>
      products.where((product) => product.isSelected);

  Iterable<CustomerSettingOption> get selectedCustomerSettingOptions sync* {
    for (var setting in CustomerSettings.instance.itemList) {
      final optionId = customerSettings[setting.id];
      final option =
          optionId == null ? setting.defaultOption : setting.getItem(optionId);

      if (option != null) {
        yield option;
      }
    }
  }

  int get totalCount {
    return products.fold(0, (value, product) => value + product.count);
  }

  num get totalPrice {
    var total = productsPrice;

    selectedCustomerSettingOptions.forEach((option) {
      total = option.calculatePrice(total);
    });

    return CurrencyProvider.instance.isInt ? total.toInt() : total;
  }

  OrderProduct add(Product product) {
    final orderProduct = OrderProduct(product, isSelected: true);
    products.add(orderProduct);

    _selectedChanged();

    return orderProduct;
  }

  void clear() {
    products.clear();
    customerSettings.clear();
    isHistoryMode = false;
    _selectedChanged();
  }

  @override
  void dispose() {
    products.clear();
    customerSettings.clear();
    super.dispose();
  }

  /// Drop the stashed order
  Future<bool> drop(int lastCount) async {
    final order = await Seller.instance.drop(lastCount);
    if (order == null) return false;

    info(order.id.toString(), 'order.cart.drop');

    replaceByObject(order);
    return true;
  }

  /// Paid to the order
  Future<bool> paid(num? paid) async {
    if (totalCount == 0) {
      clear();
      return false;
    }

    final price = totalPrice;
    paid ??= price;
    if (paid < price) throw PaidException('insufficient_amount');

    info(isHistoryMode ? 'history' : 'normal', 'order.paid.verified');
    // if history mode update data
    isHistoryMode
        ? await _finishHistoryMode(paid, price)
        : await _finishNormalMode(paid, price);

    clear();
    return true;
  }

  Future<bool> popHistory() async {
    final order = await Seller.instance.getTodayLast();
    if (order == null) return false;

    info(order.id.toString(), 'order.cart.pop');

    replaceByObject(order);
    isHistoryMode = true;

    return true;
  }

  void rebind() {
    // remove not exist product
    products.removeWhere((product) {
      return Menu.instance.items
          .every((catalog) => !catalog.hasItem(product.id));
    });
    // remove not exist customer
    customerSettings.entries.toList().forEach((entry) {
      final setting = CustomerSettings.instance.getItem(entry.key);
      if (setting == null || !setting.hasItem(entry.value)) {
        customerSettings.remove(entry.key);
      }
    });
    // rebind product ingredient/quantity
    products.forEach((product) => product.rebind());
  }

  void removeSelected() {
    products.removeWhere((e) => e.isSelected);
    _selectedChanged();
  }

  @visibleForTesting
  void replaceAll({
    List<OrderProduct>? products,
    Map<String, String>? customerSettings,
  }) {
    if (products != null) {
      this.products
        ..clear()
        ..addAll(products);
    }
    if (customerSettings != null) {
      this.customerSettings
        ..clear()
        ..addAll(customerSettings);
    }
  }

  void replaceByObject(OrderObject object) {
    products
      ..clear()
      ..addAll(object.parseToProduct());
    customerSettings
      ..clear()
      ..addAll(object.customerSettings);
    _selectedChanged();
  }

  /// Stash order to DB
  ///
  /// Return false if not storable
  /// Rate limit = 5
  Future<bool> stash() async {
    if (isEmpty) return true;

    // disallow before stash, so need minus 1
    final length = await Seller.instance.getStashCount();
    if (length > 4) return false;

    final data = await toObject();
    final id = await Seller.instance.stash(data);
    info(id.toString(), 'order.cart.stash');

    clear();

    return true;
  }

  void toggleAll(bool? checked, {OrderProduct? except}) {
    // except only acceptable when specify checked
    assert(checked != null || except == null);

    products.forEach((product) => product
        .toggleSelected(identical(product, except) ? !checked! : checked));
  }

  Future<OrderObject> toObject({
    num? paid,
    OrderObject? object,
  }) async {
    final combinationId = await _prepareCustomerSettingCombinationId();
    return OrderObject(
      id: object?.id,
      paid: paid,
      createdAt: object?.createdAt,
      customerSettings: customerSettings,
      customerSettingsCombinationId: combinationId,
      totalPrice: totalPrice,
      totalCount: totalCount,
      productsPrice: productsPrice,
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

  Future<void> _finishHistoryMode(num paid, num price) async {
    final oldData = await Seller.instance.getTodayLast();
    final data = await toObject(paid: paid, object: oldData);

    await Seller.instance.update(data);
    info(oldData?.id.toString() ?? 'unknown', 'order.paid.update');

    await Stock.instance.order(data, oldData: oldData);
    await Cashier.instance.paid(paid, price, oldData?.totalPrice);
  }

  Future<void> _finishNormalMode(num paid, num price) async {
    final data = await toObject(paid: paid);

    final id = await Seller.instance.push(data);
    info(id.toString(), 'order.paid.add');

    await Stock.instance.order(data);
    await Cashier.instance.paid(paid, price);
  }

  Future<int> _prepareCustomerSettingCombinationId() async {
    final settings = CustomerSettings.instance;
    final data = {
      for (final option in selectedCustomerSettingOptions)
        option.setting.id: option.id
    };

    final id = await settings.getCombinationId(data);
    return id ?? await settings.generateCombinationId(data);
  }

  void _selectedChanged() {
    notifyListeners();
    CartIngredients.instance.notifyListeners();
  }
}

class PaidException implements Exception {
  final String cause;

  const PaidException(this.cause);
}
