import 'package:flutter/material.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/order/order_attribute_option.dart';
import 'package:possystem/models/order/order_product.dart';
import 'package:possystem/models/repository/cart_ingredients.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/settings/currency_setting.dart';

import 'cashier.dart';
import 'seller.dart';
import 'stock.dart';

class Cart extends ChangeNotifier {
  static Cart instance = Cart();

  final List<OrderProduct> products = [];

  final Map<String, String> attributes = {};

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

  Iterable<OrderAttributeOption> get selectedAttributeOptions sync* {
    for (var attr in OrderAttributes.instance.itemList) {
      final optionId = attributes[attr.id];
      final option =
          optionId == null ? attr.defaultOption : attr.getItem(optionId);

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

    for (var option in selectedAttributeOptions) {
      total = option.calculatePrice(total);
    }

    return total.toCurrencyNum();
  }

  OrderProduct add(Product product) {
    final orderProduct = OrderProduct(product, isSelected: true);
    products.add(orderProduct);

    _selectedChanged();

    return orderProduct;
  }

  void clear() {
    products.clear();
    attributes.clear();
    isHistoryMode = false;
    _selectedChanged();
  }

  @override
  void dispose() {
    products.clear();
    attributes.clear();
    super.dispose();
  }

  /// Drop the stashed order
  Future<bool> drop(int lastCount) async {
    Log.ger('start', 'order_cart_drop');
    final order = await Seller.instance.drop(lastCount);
    if (order == null) return false;

    replaceByObject(order);
    Log.ger('done', 'order_cart_drop');

    return true;
  }

  /// Paid to the order
  Future<CashierUpdateStatus?> paid(num? paid) async {
    if (totalCount == 0) {
      clear();
      return null;
    }

    final price = totalPrice;
    paid ??= price;
    Log.ger(isHistoryMode ? 'history' : 'normal', 'order_paid');
    if (paid < price) throw const PaidException('insufficient_amount');

    Log.ger('verified', 'order_paid');
    // if history mode update data
    final result = isHistoryMode
        ? await _finishHistoryMode(paid, price)
        : await _finishNormalMode(paid, price);

    clear();
    return result;
  }

  Future<bool> popHistory() async {
    Log.ger('start', 'order_cart_pop');
    final order = await Seller.instance.getTodayLast();
    if (order == null) return false;

    replaceByObject(order);
    Log.ger('done', 'order_cart_pop');

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
    attributes.entries.toList().forEach((entry) {
      final attr = OrderAttributes.instance.getItem(entry.key);
      if (attr == null || !attr.hasItem(entry.value)) {
        attributes.remove(entry.key);
      }
    });
    // rebind product ingredient/quantity
    for (var product in products) {
      product.rebind();
    }
  }

  void removeSelected() {
    products.removeWhere((e) => e.isSelected);
    _selectedChanged();
  }

  @visibleForTesting
  void replaceAll({
    List<OrderProduct>? products,
    Map<String, String>? attributes,
  }) {
    if (products != null) {
      this.products
        ..clear()
        ..addAll(products);
    }
    if (attributes != null) {
      this.attributes
        ..clear()
        ..addAll(attributes);
    }
  }

  void replaceByObject(OrderObject object) {
    products
      ..clear()
      ..addAll(object.parseToProduct());
    attributes
      ..clear()
      ..addAll(object.attributes);
    _selectedChanged();
  }

  /// Stash order to DB
  ///
  /// Return false if not storable
  /// Rate limit = 5
  Future<bool> stash() async {
    if (isEmpty) return true;

    Log.ger('start', 'order_cart_stash');
    // disallow before stash, so need minus 1
    final length = await Seller.instance.getStashCount();
    if (length > 4) return false;

    final data = await toObject();
    await Seller.instance.stash(data);

    clear();
    Log.ger('done', 'order_cart_stash');

    return true;
  }

  void toggleAll(bool? checked, {OrderProduct? except}) {
    // except only acceptable when specify checked
    assert(checked != null || except == null);

    for (var product in products) {
      product.toggleSelected(identical(product, except) ? !checked! : checked);
    }
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
      attributes: attributes,
      customerSettingsCombinationId: combinationId,
      totalPrice: totalPrice,
      totalCount: totalCount,
      productsPrice: productsPrice,
      products: products.map<OrderProductObject>((e) => e.toObject()),
    );
  }

  void updateSelectedCount(int? count) {
    if (count == null) return;

    for (var e in selected) {
      e.count = count;
    }
    notifyListeners();
  }

  void updateSelectedDiscount(int? discount) {
    if (discount == null) return;

    for (var e in selected) {
      final price = e.singlePrice * discount / 100;
      e.singlePrice = price.toCurrencyNum();
    }
    notifyListeners();
  }

  void updateSelectedPrice(num? price) {
    if (price == null) return;

    for (var e in selected) {
      e.singlePrice = price;
    }
    notifyListeners();
  }

  Future<CashierUpdateStatus> _finishHistoryMode(num paid, num price) async {
    final oldData = await Seller.instance.getTodayLast();
    final data = await toObject(paid: paid, object: oldData);

    await Seller.instance.update(data);
    Log.ger('history done', 'order_paid');

    await Stock.instance.order(data, oldData: oldData);
    final cashierResult = await Cashier.instance.paid(
      paid,
      price,
      oldData?.totalPrice,
    );

    return cashierResult;
  }

  Future<CashierUpdateStatus> _finishNormalMode(num paid, num price) async {
    final data = await toObject(paid: paid);

    await Seller.instance.push(data);
    Log.ger('normal done', 'order_paid');

    await Stock.instance.order(data);
    final cashierResult = await Cashier.instance.paid(paid, price);

    return cashierResult;
  }

  Future<int> _prepareCustomerSettingCombinationId() async {
    return 1;
    // final settings = OrderAttributes.instance;
    // final data = {
    //   for (final option in selectedAttributeOptions)
    //     option.repository.id: option.id
    // };

    // final id = await settings.getCombinationId(data);
    // return id ?? await settings.generateCombinationId(data);
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
