import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/order/cart_product.dart';
import 'package:possystem/services/cart/cart_state.dart';

/// Service managing the cart state and basic operations.
class CartStateManager {
  static final CartStateManager instance = CartStateManager._();

  CartStateManager._();

  /// Add [product] to the cart.
  void add(CartState state, Product product) {
    final p = CartProduct(product, isSelected: true);
    state.products.add(p);
    _toggleAll(state, false, except: p);
    _notifyStateChanged(state);
  }

  /// Update [attributes] by setting the entry.
  void chooseAttribute(CartState state, String attrId, String optionId) {
    state.attributes[attrId] = optionId;
    _notifyStateChanged(state);
  }

  /// Update the note of the order.
  void updateNote(CartState state, String value) {
    state.note = value;
    _notifyStateChanged(state);
  }

  /// Update the kitchen note on a single cart line.
  void updateProductNote(CartState state, CartProduct product, String value) {
    product.note = value;
    _notifyStateChanged(state);
  }

  /// Bind the cart to a dining table (dine-in workflow).
  void bindTable(CartState state, {required String tableId, int? pax}) {
    state.tableId = tableId;
    state.pax = pax;
    _notifyStateChanged(state);
  }

  /// Toggle all selection of products.
  void toggleAll(CartState state, bool? checked, {CartProduct? except}) {
    // except only acceptable when specify checked
    assert(checked != null || except == null);

    for (var product in state.products) {
      product.toggleSelected(identical(product, except) ? !checked! : checked);
    }

    _updateSelection(state);
    _notifyStateChanged(state);
  }

  void _toggleAll(CartState state, bool? checked, {CartProduct? except}) {
    // except only acceptable when specify checked
    assert(checked != null || except == null);

    for (var product in state.products) {
      product.toggleSelected(identical(product, except) ? !checked! : checked);
    }

    _updateSelection(state);
  }

  void _updateSelection(CartState state) {
    final selected = state.selected;
    if (selected.isEmpty) {
      state.selectedProduct.value = null;
      state.selectedIndex = -1;
      return;
    }

    final s = selected.first;
    state.selectedIndex = state.products.indexOf(s);
    state.selectedProduct.value = selected.every((e) => e.id == s.id)
        ? s
        : null;
  }

  /// Remove all selected product.
  void selectedRemove(CartState state) {
    state.products.removeWhere((e) => e.isSelected);
    state.selectedProduct.value = null;
    _notifyStateChanged(state);
  }

  /// Change the count of selected products.
  void selectedUpdateCount(CartState state, int? count) {
    if (count == null) return;

    for (var e in state.selected) {
      e.count = count;
    }
    _notifyStateChanged(state);
  }

  /// Change the price of selected products by discount.
  void selectedUpdateDiscount(CartState state, int? discount) {
    if (discount == null) return;

    for (var e in state.selected) {
      final price = e.product.price * discount / 100;
      e.singlePrice = price.toCurrencyNum();
    }
    _notifyStateChanged(state);
  }

  /// Change the price of selected products.
  void selectedUpdatePrice(CartState state, num? price) {
    if (price == null) return;

    for (var e in state.selected) {
      e.singlePrice = price.toCurrencyNum();
    }
    _notifyStateChanged(state);
  }

  /// Remove specific product
  void removeAt(CartState state, int index) {
    state.products.removeAt(index);
    _updateSelection(state);
    _notifyStateChanged(state);
  }

  /// Apply [delta] to the product at [index].
  ///
  /// Removes the line when the resulting count would drop below 1.
  void updateQuantity(CartState state, int index, int delta) {
    if (index < 0 || index >= state.products.length || delta == 0) return;

    final product = state.products[index];
    final next = product.count + delta;
    if (next < 1) {
      removeAt(state, index);
      return;
    }

    product.count = next;
    _notifyStateChanged(state);
  }

  /// Public function to let watcher knows the price has changed.
  void priceChanged(CartState state) {
    _notifyStateChanged(state);
  }

  /// Clear all the status.
  void clear(CartState state) {
    state.products.clear();
    state.attributes.clear();
    state.selectedProduct.value = null;
    state.note = '';
    state.tableId = null;
    state.pax = null;
    state.stashId = null;
    _notifyStateChanged(state);
  }

  void _notifyStateChanged(CartState state) {
    // This is a placeholder - in a real implementation, this would notify listeners
    // For now, we rely on the individual CartProduct notifying changes
  }
}
