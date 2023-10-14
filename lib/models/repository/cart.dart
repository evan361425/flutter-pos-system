import 'dart:math';

import 'package:flutter/material.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/order/order_attribute_option.dart';
import 'package:possystem/models/order/cart_product.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/settings/currency_setting.dart';

import 'cashier.dart';
import 'seller.dart';
import 'stock.dart';

/// Collect current cart status.
///
/// Notify when any product's count/price changed or product added/removed.
class Cart extends ChangeNotifier {
  /// Singleton on [Cart].
  static Cart instance = Cart();

  /// Timer for order creation.
  @visibleForTesting
  static DateTime Function() timer = () => DateTime.now();

  /// Current ordered products.
  final List<CartProduct> products = [];

  /// Current select attributes.
  final Map<String, String> attributes = {};

  /// Current paid money.
  ValueNotifier<num?> currentPaid = ValueNotifier(null);

  /// Current selected product if and only if all selected products are same.
  final ValueNotifier<CartProduct?> selectedProduct = ValueNotifier(null);

  /// Whether cart is empty and can be recovered by stashed data without any
  /// side effect.
  bool get isEmpty => products.isEmpty;

  /// The sum of all products price.
  num get productsPrice {
    return products.fold(0, (value, product) => value + product.totalPrice);
  }

  /// The sum of all products cost which is also the order's cost.
  num get productsCost {
    return products.fold(0, (value, product) => value + product.totalCost);
  }

  /// The count of all ordered products.
  int get productCount {
    return products.fold(0, (value, product) => value + product.count);
  }

  /// Order's price, the sum of product and attribute.
  num get price {
    var total = productsPrice;

    for (var option in selectedAttributeOptions) {
      total = option.calculatePrice(total);
    }

    return max(total.toCurrencyNum(), 0);
  }

  /// The list of selected product.
  Iterable<CartProduct> get selected =>
      products.where((product) => product.isSelected);

  /// The attribute options that are selected or default value.
  Iterable<OrderAttributeOption> get selectedAttributeOptions sync* {
    for (var attr in OrderAttributes.instance.itemList) {
      final id = attributes[attr.id];
      final option = id == null ? attr.defaultOption : attr.getItem(id);

      if (option != null) {
        yield option;
      }
    }
  }

  /// Add [product] to the cart.
  void add(Product product) {
    final p = CartProduct(product, isSelected: true);
    products.add(p);

    toggleAll(false, except: p);

    notifyListeners();
  }

  /// Finish the order and get paid.
  Future<CashierUpdateStatus?> checkout() async {
    if (isEmpty) return null;

    final price = this.price;
    final paid = currentPaid.value ?? price;
    if (paid < price) throw const PaidException('insufficient_amount');

    Log.ger('start', 'order_paid');

    final data = toObject(paid: paid);
    await Seller.instance.push(data);
    await Stock.instance.order(data);
    final result = await Cashier.instance.paid(paid, price);

    clear();

    return result;
  }

  /// When start ordering, the properties should rebind to avoid legacy data.
  void rebind() {
    // remove not exist product
    products.removeWhere((product) {
      return Menu.instance.items
          .every((catalog) => !catalog.hasItem(product.id));
    });
    // remove non exist attribute
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

  /// Stash order to restore later.
  Future<bool> stash() async {
    if (isEmpty) return false;

    Log.ger('start', 'order_cart_stash');

    await Seller.instance.stash(toObject());

    clear();

    return true;
  }

  /// Restore the order.
  Future<bool> restore(int id) async {
    Log.ger('start', 'order_cart_restore');

    final order = await Seller.instance.dropStashedOrder(id);
    if (order == null) return false;

    _replaceByObject(order);

    return true;
  }

  /// Toggle all selection of products.
  void toggleAll(bool? checked, {CartProduct? except}) {
    // except only acceptable when specify checked
    assert(checked != null || except == null);

    for (var product in products) {
      product.toggleSelected(identical(product, except) ? !checked! : checked);
    }

    updateSelection();
  }

  void updateSelection() {
    final selected = this.selected;
    if (selected.isEmpty) {
      // TODO: testing
      selectedProduct.value = null;
      return;
    }

    final s = selected.first;
    selectedProduct.value = selected.every((e) => e.id == s.id) ? s : null;
  }

  /// Remove all selected product.
  void selectedRemove() {
    products.removeWhere((e) => e.isSelected);

    selectedProduct.value = null;
    notifyListeners();
  }

  /// Change the count of selected products.
  void selectedUpdateCount(int? count) {
    if (count == null) return;

    for (var e in selected) {
      e.count = count;
    }
    notifyListeners();
  }

  /// Change the price of selected products by discount.
  ///
  /// It use original price to calculate the final price.
  void selectedUpdateDiscount(int? discount) {
    if (discount == null) return;

    for (var e in selected) {
      final price = e.product.price * discount / 100;
      e.singlePrice = price.toCurrencyNum();
    }
    notifyListeners();
  }

  /// Change the price of selected products.
  void selectedUpdatePrice(num? price) {
    if (price == null) return;

    for (var e in selected) {
      e.singlePrice = price.toCurrencyNum();
    }
    notifyListeners();
  }

  /// Public function to let watcher knows the price has changed.
  ///
  /// For example: quantity selection.
  void priceChanged() {
    notifyListeners();
  }

  /// Replace current status from [object].
  void _replaceByObject(OrderObject object) {
    products
      ..clear()
      ..addAll(object.productModels);
    attributes
      ..clear()
      ..addAll(object.selectedAttributes);
    currentPaid.value = null;
    selectedProduct.value = null;

    notifyListeners();
  }

  /// Clear all the status.
  void clear() {
    products.clear();
    attributes.clear();
    currentPaid.dispose();
    currentPaid = ValueNotifier(null);
    selectedProduct.value = null;

    notifyListeners();
  }

  @override
  void dispose() {
    products.clear();
    attributes.clear();
    super.dispose();
  }

  @visibleForTesting
  void replaceAll({
    List<CartProduct>? products,
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

  /// Cart status to [OrderObject]
  OrderObject toObject({num paid = 0}) {
    return OrderObject(
      paid: paid,
      cost: productsCost,
      price: price,
      productsCount: productCount,
      productsPrice: productsPrice,
      products: products.map<OrderProductObject>((e) => e.toObject()).toList(),
      attributes: selectedAttributeOptions
          .map((e) => OrderSelectedAttributeObject.fromModel(e))
          .toList(),
      createdAt: timer(),
    );
  }
}

class PaidException implements Exception {
  final String cause;

  const PaidException(this.cause);
}
