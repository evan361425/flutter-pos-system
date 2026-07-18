import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/order/cart_product.dart';
import 'package:possystem/models/order/order_attribute_option.dart';
import 'package:possystem/models/order/payment_intent.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/services/cart/cart_state.dart';
import 'package:possystem/services/cart/cart_state_manager.dart';
import 'package:possystem/services/cart/checkout_service.dart';
import 'package:possystem/services/cart/stash_service.dart';

export 'package:possystem/services/cart/checkout_service.dart'
    show CheckoutStatus;

/// Collect current cart status.
///
/// Notify when any product's count/price changed or product added/removed.
class Cart extends ChangeNotifier {
  /// Singleton on [Cart].
  static Cart instance = Cart();

  Cart({this.name = 'cart'});

  /// Timer for order creation (delegates to [CartState.timer]).
  @visibleForTesting
  static DateTime Function() get timer => CartState.timer;
  @visibleForTesting
  static set timer(DateTime Function() value) => CartState.timer = value;

  /// Help analysis checkout is from stashed or actual cart.
  final String name;

  /// Internal state holder
  final CartState _state = CartState();

  List<CartProduct> get products => _state.products;
  Map<String, String> get attributes => _state.attributes;
  ValueNotifier<CartProduct?> get selectedProduct => _state.selectedProduct;
  String get note => _state.note;
  set note(String value) => _state.note = value;
  int get selectedIndex => _state.selectedIndex;
  set selectedIndex(int value) => _state.selectedIndex = value;

  /// Linked dining table UUID for dine-in; null for takeaway.
  String? get tableId => _state.tableId;

  /// Guest count; null means takeaway / unset.
  int? get pax => _state.pax;

  /// Stash row id when restored from [StashedOrders]; null otherwise.
  int? get stashId => _state.stashId;

  bool get isEmpty => _state.isEmpty;
  num get productsPrice => _state.productsPrice;
  num get productsCost => _state.productsCost;
  int get productCount => _state.productCount;
  num get totalTax => _state.totalTax;
  num get subtotal => _state.subtotal;
  num get price => _state.price;
  Iterable<CartProduct> get selected => _state.selected;
  Iterable<OrderAttributeOption> get selectedAttributeOptions =>
      _state.selectedAttributeOptions;

  void add(Product product) {
    CartStateManager.instance.add(_state, product);
    notifyListeners();
  }

  void chooseAttribute(String attrId, String optionId) {
    CartStateManager.instance.chooseAttribute(_state, attrId, optionId);
    notifyListeners();
  }

  void updateNote(String value) {
    CartStateManager.instance.updateNote(_state, value);
    notifyListeners();
  }

  /// Update the kitchen note on a single [product] line.
  void updateProductNote(CartProduct product, String value) {
    CartStateManager.instance.updateProductNote(_state, product, value);
    notifyListeners();
  }

  /// Bind this cart to a dining table before taking the order.
  void bindTable({required String tableId, int? pax}) {
    CartStateManager.instance.bindTable(_state, tableId: tableId, pax: pax);
    notifyListeners();
  }

  /// Finish the order with typed [payments].
  Future<CheckoutStatus> checkout({
    required List<PaymentIntent> payments,
    required BuildContext context,
  }) async {
    final status = await CheckoutService.instance.checkout(
      state: _state,
      payments: payments,
      context: context,
    );
    if (status == CheckoutStatus.ok ||
        status == CheckoutStatus.cashierNotEnough ||
        status == CheckoutStatus.cashierUsingSmall) {
      notifyListeners();
    }
    return status;
  }

  void rebind() {
    _state.products.removeWhere((product) {
      return Menu.instance.items.every(
        (catalog) => !catalog.hasItem(product.id),
      );
    });
    _state.attributes.entries.toList().forEach((entry) {
      final attr = OrderAttributes.instance.getItem(entry.key);
      if (attr == null || !attr.hasItem(entry.value)) {
        _state.attributes.remove(entry.key);
      }
    });
    for (var product in _state.products) {
      product.rebind();
    }
    notifyListeners();
  }

  Future<bool> stash() async {
    Log.ger('begin_order_stash');
    final ok = await StashService.instance.stash(_state);
    if (ok) {
      notifyListeners();
    }
    return ok;
  }

  void restore(OrderObject order) {
    Log.ger('begin_order_restore');
    StashService.instance.restore(_state, order);
    notifyListeners();
  }

  void toggleAll(bool? checked, {CartProduct? except}) {
    CartStateManager.instance.toggleAll(_state, checked, except: except);
    notifyListeners();
  }

  void updateSelection() {
    _updateSelection();
    notifyListeners();
  }

  void _updateSelection() {
    final selected = _state.selected;
    if (selected.isEmpty) {
      _state.selectedProduct.value = null;
      _state.selectedIndex = -1;
      return;
    }

    final s = selected.first;
    _state.selectedIndex = _state.products.indexOf(s);
    _state.selectedProduct.value = selected.every((e) => e.id == s.id)
        ? s
        : null;
  }

  void selectedRemove() {
    CartStateManager.instance.selectedRemove(_state);
    notifyListeners();
  }

  void selectedUpdateCount(int? count) {
    CartStateManager.instance.selectedUpdateCount(_state, count);
    notifyListeners();
  }

  void selectedUpdateDiscount(int? discount) {
    CartStateManager.instance.selectedUpdateDiscount(_state, discount);
    notifyListeners();
  }

  void selectedUpdatePrice(num? price) {
    CartStateManager.instance.selectedUpdatePrice(_state, price);
    notifyListeners();
  }

  void removeAt(int index) {
    CartStateManager.instance.removeAt(_state, index);
    notifyListeners();
  }

  /// Apply [delta] to the product at [index] (see [CartStateManager.updateQuantity]).
  void updateQuantity(int index, int delta) {
    CartStateManager.instance.updateQuantity(_state, index, delta);
    notifyListeners();
  }

  void priceChanged() {
    CartStateManager.instance.priceChanged(_state);
    notifyListeners();
  }

  void clear() {
    CartStateManager.instance.clear(_state);
    notifyListeners();
  }

  @override
  void dispose() {
    _state.products.clear();
    _state.attributes.clear();
    super.dispose();
  }

  @visibleForTesting
  void replaceAll({
    List<CartProduct>? products,
    Map<String, String>? attributes,
  }) {
    if (products != null) {
      _state.products
        ..clear()
        ..addAll(products);
    }
    if (attributes != null) {
      _state.attributes
        ..clear()
        ..addAll(attributes);
    }
    notifyListeners();
  }

  OrderObject toObject({List<PaymentIntent>? payments, num paid = 0}) {
    return _state.toObject(payments: payments, paid: paid);
  }
}
