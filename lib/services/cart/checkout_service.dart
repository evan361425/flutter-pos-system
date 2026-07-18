import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/order/payment_intent.dart';
import 'package:possystem/models/printer_config.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/models/repository/stashed_orders.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/tables/table_status.dart';
import 'package:possystem/services/cart/cart_state.dart';
import 'package:possystem/services/cart/cart_state_manager.dart';
import 'package:possystem/services/cart/receipt_service.dart';
import 'package:possystem/services/integration/cloud_sync_service.dart';
import 'package:possystem/services/printer/printer_config_store.dart';
import 'package:possystem/services/shift/shift_manager_service.dart';
import 'package:possystem/services/staff/employee_manager_service.dart';
import 'package:possystem/services/sync/sync_service.dart';
import 'package:possystem/services/tables/table_manager_service.dart';

/// Pure helpers for mixed-tender cash-drawer math (testable without Flutter).
class CheckoutCashMath {
  const CheckoutCashMath._();

  /// Sum of all tender amounts.
  static num totalPaid(Iterable<PaymentIntent> payments) {
    return payments.fold<num>(0, (sum, p) => sum + p.amount);
  }

  /// Cash tender only.
  static num cashPaid(Iterable<PaymentIntent> payments) {
    return payments
        .where((p) => p.method == PaymentMethod.cash)
        .fold<num>(0, (sum, p) => sum + p.amount);
  }

  /// Non-cash tender (card / voucher). Tips on card stay here — never change.
  static num nonCashPaid(Iterable<PaymentIntent> payments) {
    return payments
        .where((p) => p.method != PaymentMethod.cash)
        .fold<num>(0, (sum, p) => sum + p.amount);
  }

  /// Portion of [grandTotal] that must still be covered by cash after non-cash.
  static num cashDue({
    required Iterable<PaymentIntent> payments,
    required num grandTotal,
  }) {
    return max(0, grandTotal - nonCashPaid(payments));
  }

  /// Change returned from the cash drawer (never from card overpayment).
  static num change({
    required Iterable<PaymentIntent> payments,
    required num grandTotal,
  }) {
    return max(
      0,
      cashPaid(payments) - cashDue(payments: payments, grandTotal: grandTotal),
    );
  }
}

/// Service handling the checkout process.
///
/// Contract:
/// - Local persistence (Seller, Stock, Cashier) is awaited so the sale is
///   guaranteed to be committed to SQLite before returning to the caller.
/// - Cloud sync and hardware side-effects (printing) are fire-and-forget so
///   a broken network or a missing printer never blocks the till (Law 3.1 /
///   3.3 / 3.4 of .cursorrules).
/// - On any committed status ([CheckoutStatus.ok], [CheckoutStatus.cashierNotEnough],
///   [CheckoutStatus.cashierUsingSmall]) the cart is emptied atomically to
///   prevent double-charging if the operator re-taps the checkout button.
class CheckoutService {
  static final CheckoutService instance = CheckoutService._();

  CheckoutService._({
    Future<void> Function(OrderObject)? pushOrder,
    Future<void> Function(OrderObject)? stockOrder,
    Future<CashierUpdateStatus> Function(num paid, num price)? cashierPaid,
    Future<ReceiptData?> Function({
      required BuildContext context,
      required OrderObject order,
    })?
    generateReceipts,
    void Function(ReceiptData)? printReceipts,
    Future<void> Function(OrderObject)? dispatchOrder,
    Future<int> Function(Object payload, String endpoint)? enqueue,
    void Function(CartState)? clearCart,
    bool Function()? hasSmartCashier,
  }) : _pushOrder = pushOrder,
       _stockOrder = stockOrder,
       _cashierPaid = cashierPaid,
       _generateReceipts = generateReceipts,
       _printReceipts = printReceipts,
       _dispatchOrder = dispatchOrder,
       _enqueue = enqueue,
       _clearCart = clearCart,
       _hasSmartCashierOverride = hasSmartCashier;

  /// Test seam: inject collaborators so checkout can be verified without the
  /// Flutter engine or real SQLite / hardware (Law 5.6).
  @visibleForTesting
  factory CheckoutService.forTest({
    required Future<void> Function(OrderObject) pushOrder,
    required Future<void> Function(OrderObject) stockOrder,
    required Future<CashierUpdateStatus> Function(num paid, num price)
    cashierPaid,
    required Future<int> Function(Object payload, String endpoint) enqueue,
    Future<void> Function(OrderObject)? dispatchOrder,
    void Function(CartState)? clearCart,
    bool hasSmartCashier = true,
  }) {
    return CheckoutService._(
      pushOrder: pushOrder,
      stockOrder: stockOrder,
      cashierPaid: cashierPaid,
      enqueue: enqueue,
      dispatchOrder: dispatchOrder ?? (_) async {},
      clearCart: clearCart ?? ((state) => state.products.clear()),
      hasSmartCashier: () => hasSmartCashier,
      generateReceipts: ({required context, required order}) async => null,
      printReceipts: (_) {},
    );
  }

  final Future<void> Function(OrderObject)? _pushOrder;
  final Future<void> Function(OrderObject)? _stockOrder;
  final Future<CashierUpdateStatus> Function(num paid, num price)? _cashierPaid;
  final Future<ReceiptData?> Function({
    required BuildContext context,
    required OrderObject order,
  })?
  _generateReceipts;
  final void Function(ReceiptData)? _printReceipts;
  final Future<void> Function(OrderObject)? _dispatchOrder;
  final Future<int> Function(Object payload, String endpoint)? _enqueue;
  final void Function(CartState)? _clearCart;
  final bool Function()? _hasSmartCashierOverride;

  /// Execute the checkout process with typed [payments].
  ///
  /// [context] is required only for the legacy Bluetooth receipt pipeline.
  ///
  /// When [releaseTable] is false (partial / split-bill checkout), the dining
  /// table status is left untouched so the caller can free it only after the
  /// remaining stash is empty.
  Future<CheckoutStatus> checkout({
    required CartState state,
    required List<PaymentIntent> payments,
    BuildContext? context,
    bool releaseTable = true,
  }) async {
    if (state.isEmpty) return CheckoutStatus.nothingHappened;

    final totalPaid = CheckoutCashMath.totalPaid(payments);
    if (totalPaid < state.price) return CheckoutStatus.paidNotEnough;

    Log.ger('begin_order_checkout', {
      'totalPaid': totalPaid,
      'price': state.price,
      'totalTax': state.totalTax,
      'methods': payments.map((p) => p.method.name).toList(),
    });
    final data = _toOrderObject(state, payments: payments);

    final useSmartCashier = _hasSmartCashierPrinter();
    if (!useSmartCashier && context != null) {
      final receipt =
          await (_generateReceipts ?? ReceiptService.instance.generateReceipts)(
            context: context,
            order: data,
          );
      if (receipt != null) {
        _fireAndForgetLegacyPrint(receipt);
      }
    }

    await (_pushOrder ?? Seller.instance.push)(data);
    await (_stockOrder ?? Stock.instance.order)(data);

    final cashierStatus = await _updateCashDrawer(
      payments: payments,
      grandTotal: data.price,
    );

    unawaited((_dispatchOrder ?? ReceiptService.instance.dispatchOrder)(data));

    unawaited(
      (_enqueue ?? SyncService.instance.enqueue)(
        data.toMap(),
        'orders',
      ).catchError((Object e, StackTrace stack) {
        Log.err(e, 'sync_enqueue_failed', stack);
        return 0;
      }),
    );

    // Outbound e-commerce inventory: outbox via CloudSyncService (never blocks till).
    unawaited(CloudSyncService.instance.decrementOnlineStock(data));

    final checkoutStatus = CheckoutStatus.fromCashier(cashierStatus);

    if (_isCommitted(checkoutStatus)) {
      // Capture before clear() nulls tableId / pax.
      final tableId = state.tableId;
      if (releaseTable && tableId != null) {
        try {
          await TableManagerService.instance.updateTableStatus(
            tableId,
            TableStatus.available,
          );
        } catch (e, stack) {
          Log.err(e, 'table_free_failed', stack);
        }
        try {
          final stashed = await StashedOrders.instance.getByTableId(tableId);
          if (stashed?.id != null) {
            await StashedOrders.instance.delete(stashed!.id!);
          }
        } catch (e, stack) {
          Log.err(e, 'stash_evict_on_checkout_failed', stack);
        }
      }
      (_clearCart ?? CartStateManager.instance.clear)(state);
    }

    return checkoutStatus;
  }

  /// Only cash tender moves the drawer. Card overpayment is tip, not change.
  Future<CashierUpdateStatus> _updateCashDrawer({
    required List<PaymentIntent> payments,
    required num grandTotal,
  }) async {
    final cash = CheckoutCashMath.cashPaid(payments);
    final due = CheckoutCashMath.cashDue(
      payments: payments,
      grandTotal: grandTotal,
    );

    // Pure non-cash sale: no drawer mutation.
    if (cash == 0 && due == 0) {
      return CashierUpdateStatus.ok;
    }

    try {
      return await (_cashierPaid ?? Cashier.instance.paid)(cash, due);
    } catch (e, stack) {
      Log.err(e, 'cashier_paid_failed', stack);
      return CashierUpdateStatus.ok;
    }
  }

  bool _hasSmartCashierPrinter() {
    if (_hasSmartCashierOverride != null) {
      return _hasSmartCashierOverride!();
    }
    try {
      final store = PrinterConfigStore.instance;
      if (!store.initialized) return false;
      return store.items.any((c) => c.role == PrinterRole.cashier);
    } catch (_) {
      return false;
    }
  }

  void _fireAndForgetLegacyPrint(ReceiptData receipt) {
    try {
      (_printReceipts ?? ReceiptService.instance.printReceipts)(receipt);
    } catch (e, st) {
      Log.err(e, 'legacy_print_failed', st);
    }
  }

  bool _isCommitted(CheckoutStatus status) {
    return status == .ok ||
        status == .cashierNotEnough ||
        status == .cashierUsingSmall;
  }

  OrderObject _toOrderObject(
    CartState state, {
    required List<PaymentIntent> payments,
  }) {
    return OrderObject(
      payments: payments,
      totalTax: state.totalTax,
      cost: state.productsCost,
      price: state.price,
      productsCount: state.productCount,
      productsPrice: state.productsPrice,
      note: state.note,
      products: state.products
          .map<OrderProductObject>((e) => e.toObject())
          .toList(),
      attributes: state.selectedAttributeOptions
          .map((e) => OrderSelectedAttributeObject.fromModel(e))
          .toList(),
      createdAt: CartState.timer(),
      tableId: state.tableId,
      pax: state.pax,
      employeeId: EmployeeManagerService.instance.currentEmployee?.id,
      shiftId: ShiftManagerService.instance.currentShift?.id,
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
    return switch (status) {
      .notEnough => CheckoutStatus.cashierNotEnough,
      .usingSmall => CheckoutStatus.cashierUsingSmall,
      .ok => CheckoutStatus.ok,
    };
  }
}
