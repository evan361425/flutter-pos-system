import 'dart:math';

import 'package:flutter/material.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/order/cart_product.dart';
import 'package:possystem/models/order/order_attribute_option.dart';
import 'package:possystem/models/order/payment_intent.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/services/shift/shift_manager_service.dart';
import 'package:possystem/services/staff/employee_manager_service.dart';

/// CartState holds the mutable state of the cart.
/// This is a plain data class (not a ChangeNotifier) that holds all cart state.
class CartState {
  /// Timer for order creation.
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

  /// Linked dining table UUID for dine-in; null for takeaway / counter.
  String? tableId;

  /// Guest count (couverts). Null means "no pax" (takeaway), distinct from 0.
  int? pax;

  /// Row id in `order_stash` when this cart was restored from a stashed order.
  /// Null for takeaway / never-stashed carts.
  int? stashId;

  /// Current selected product index.
  int selectedIndex = -1;

  CartState({this.name = 'cart'});

  /// Whether cart is empty and can be recovered by stashed data without any side effect.
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

  /// Tax across cart lines: Σ (linePrice × taxRate / 100).
  num get totalTax {
    final tax = products.fold<num>(0, (sum, p) => sum + p.lineTax);
    return max(tax.toCurrencyNum(), 0);
  }

  /// Products + order attributes, before tax.
  num get subtotal {
    var total = productsPrice;

    for (var option in selectedAttributeOptions) {
      total = option.calculatePrice(total);
    }

    return max(total.toCurrencyNum(), 0);
  }

  /// Grand total: [subtotal] + [totalTax].
  num get price => max((subtotal + totalTax).toCurrencyNum(), 0);

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

  /// Convert state to OrderObject.
  OrderObject toObject({List<PaymentIntent>? payments, num paid = 0}) {
    return OrderObject(
      id: stashId,
      payments: payments,
      paid: paid,
      totalTax: totalTax,
      cost: productsCost,
      price: price,
      productsCount: productCount,
      productsPrice: productsPrice,
      note: note,
      products: products.map<OrderProductObject>((e) => e.toObject()).toList(),
      attributes: selectedAttributeOptions
          .map((e) => OrderSelectedAttributeObject.fromModel(e))
          .toList(),
      createdAt: timer(),
      tableId: tableId,
      pax: pax,
      employeeId: EmployeeManagerService.instance.currentEmployee?.id,
      shiftId: ShiftManagerService.instance.currentShift?.id,
    );
  }
}
