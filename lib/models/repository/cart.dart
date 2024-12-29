import 'dart:math';

import 'package:flutter/material.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/order/cart_product.dart';
import 'package:possystem/models/order/order_attribute_option.dart';
import 'package:possystem/models/printer.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/stashed_orders.dart';

import 'cashier.dart';
import 'seller.dart';
import 'stock.dart';

/// Collect current cart status.
///
/// Notify when any product's count/price changed or product added/removed.
class Cart extends ChangeNotifier {
  /// Singleton on [Cart].
  static Cart instance = Cart();

  Cart({this.name = 'cart'});

  /// Timer for order creation.
  @visibleForTesting
  static DateTime Function() timer = () => DateTime.now();

  /// Help analysis checkout is from stashed or actual cart.
  final String name;

  /// Current ordered products.
  final List<CartProduct> products = [];

  /// Current select attributes.
  final Map<String, String> attributes = {};

  /// Current selected product if and only if all selected products are same.
  final ValueNotifier<CartProduct?> selectedProduct = ValueNotifier(null);

  /// Note for the order.
  String note = '';

  /// Current selected product index.
  int selectedIndex = -1;

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
  Iterable<CartProduct> get selected => products.where((product) => product.isSelected);

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

  /// Update [attributes] by setting the entry.
  ///
  /// If you want to disable the specific attribute, try passing empty string,
  /// because remove it will choose default one after checkout.
  void chooseAttribute(String attrId, String optionId) {
    attributes[attrId] = optionId;
  }

  /// Update the note of the order.
  void updateNote(String value) {
    note = value;
  }

  /// Finish the order and get paid.
  ///
  /// - [paid] is the money that customer paid. If it is less than the price,
  ///  will return [CheckoutStatus.paidNotEnough].
  /// - [context] is the context to show the receipt dialog.
  Future<CheckoutStatus> checkout({
    required num paid,
    required BuildContext context,
  }) async {
    if (isEmpty) return CheckoutStatus.nothingHappened;

    if (paid < price) return CheckoutStatus.paidNotEnough;

    Log.ger('begin_order_checkout', {'name': name, 'paid': paid, 'price': price});
    final data = toObject(paid: paid);

    final receipt = await Printers.instance.generateReceipts(context: context, order: data);
    if (receipt != null) {
      Printers.instance.printReceipts(receipt);
    }

    await Seller.instance.push(data);
    await Stock.instance.order(data);
    final status = await Cashier.instance.paid(paid, data.price);

    // After all the process, clear the cart.
    // If any error occurred, the cart will not be cleared and the decision will
    // be made by the user (re-try or discard).
    clear();

    return CheckoutStatus.fromCashier(status);
  }

  /// When start ordering, the properties should rebind to avoid legacy data.
  void rebind() {
    // remove not exist product
    products.removeWhere((product) {
      return Menu.instance.items.every((catalog) => !catalog.hasItem(product.id));
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
    final able = !Cart.instance.isEmpty;

    if (able) {
      Log.ger('begin_order_stash');

      await StashedOrders.instance.stash(toObject());

      clear();
    }

    return able;
  }

  /// Restore the order.
  void restore(OrderObject order) {
    Log.ger('begin_order_restore');

    products
      ..clear()
      ..addAll(order.productModels);
    attributes
      ..clear()
      ..addAll(order.selectedAttributes);
    selectedProduct.value = null;

    notifyListeners();
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
      selectedProduct.value = null;
      selectedIndex = -1;
      return;
    }

    final s = selected.first;
    selectedIndex = products.indexOf(s);
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

  /// Remove specific product
  void removeAt(int index) {
    products.removeAt(index);

    updateSelection();
    notifyListeners();
  }

  /// Public function to let watcher knows the price has changed.
  ///
  /// For example: quantity selection.
  void priceChanged() {
    notifyListeners();
  }

  /// Clear all the status.
  void clear() {
    products.clear();
    attributes.clear();
    selectedProduct.value = null;
    note = '';

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
      note: note,
      products: products.map<OrderProductObject>((e) => e.toObject()).toList(),
      attributes: selectedAttributeOptions.map((e) => OrderSelectedAttributeObject.fromModel(e)).toList(),
      createdAt: timer(),
    );
  }
}

/// Status of cart after checkout.
enum CheckoutStatus {
  /// The paid is not enough, checkout process has suspend.
  paidNotEnough,

  /// The money is not enough for the change.
  cashierNotEnough,

  /// Cashier is trying to use small money to paid the change.
  ///
  /// For example, need $35 to return but use two $10 and three $5 not three $10
  /// one $5.
  ///
  /// If cashier is unable to return fully, it will get [CheckoutStatus.cashierUsingSmall].
  cashierUsingSmall,

  /// Cart is empty, checkout has no other side effect.
  nothingHappened,

  /// Stash the order.
  stash,

  /// Restore from stashed.
  restore,

  /// All fine.
  ok;

  factory CheckoutStatus.fromCashier(CashierUpdateStatus status) {
    switch (status) {
      case CashierUpdateStatus.notEnough:
        return CheckoutStatus.cashierNotEnough;
      case CashierUpdateStatus.usingSmall:
        return CheckoutStatus.cashierUsingSmall;
      case CashierUpdateStatus.ok:
        return CheckoutStatus.ok;
    }
  }
}
