import 'package:possystem/helpers/logger.dart';
import 'package:posystem/models/objects/order_object.dart';
import 'package:possystem/models/order/payment_intent.dart';
import 'package:possystem/models/repository/stashed_orders.dart';
import 'package:possystem/models/tables/table_status.dart';
import 'package:possystem/services/cart/cart_state.dart';
import 'package:possystem/services/cart/checkout_service.dart';
import 'package:possystem/services/cart/stash_service.dart';
import 'package:possystem/services/tables/table_manager_service.dart';

/// Extracts selected lines from a dine-in stashed order, checks them out as a
/// new sale, and persists whatever remains on the table.
///
/// Transactional contract (checkout-first):
/// 1. Build an in-memory partial cart — no stash mutation yet.
/// 2. Await [CheckoutService.checkout] (SQLite commit for sale + stock).
/// 3. Only after a committed status: update / delete the stash and table.
///
/// If step 2 fails, the original stash is untouched (no lost items).
/// If step 3 fails after a successful sale, we log and return false so the
/// UI can surface the anomaly; paid lines may still appear on the table
/// (recoverable) rather than unpaid lines vanishing (catastrophic).
class SplitBillService {
  static final SplitBillService instance = ._();

  SplitBillService._();

  /// Pay [selectedItemsToPay] out of [originalStashedOrder], leave the rest.
  Future<bool> processPartialCheckout({
    required OrderObject originalStashedOrder,
    required List<OrderProductObject> selectedItemsToPay,
    required List<PaymentIntent> payments,
  }) async {
    if (selectedItemsToPay.isEmpty) {
      Log.ger('split_bill_empty_selection');
      return false;
    }
    if (payments.isEmpty) {
      Log.ger('split_bill_empty_payments');
      return false;
    }

    final remainingProducts = _remainingProducts(
      original: originalStashedOrder.products,
      selected: selectedItemsToPay,
    );

    Log.ger('split_bill_begin', {
      'stashId': originalStashedOrder.id,
      'tableId': originalStashedOrder.tableId,
      'selectedCount': selectedItemsToPay.length,
      'remainingCount': remainingProducts.length,
    });

    // Phase 1 — commit money / stock on a temporary cart (stash untouched).
    final partialState = _buildPartialState(
      original: originalStashedOrder,
      selected: selectedItemsToPay,
    );

    final CheckoutStatus status;
    try {
      status = await CheckoutService.instance.checkout(
        state: partialState,
        payments: payments,
        releaseTable: false,
      );
    } catch (e, stack) {
      Log.err(e, 'split_bill_checkout_failed', stack);
      return false;
    }

    if (!_isCommitted(status)) {
      Log.ger('split_bill_checkout_rejected', {'status': status.name});
      return false;
    }

    // Phase 2 — post-commit stash / table reconciliation.
    try {
      await _reconcileStashAfterPayment(
        original: originalStashedOrder,
        remainingProducts: remainingProducts,
      );
    } catch (e, stack) {
      Log.err(e, 'split_bill_stash_reconcile_failed', stack);
      return false;
    }

    Log.ger('split_bill_ok', {
      'tableId': originalStashedOrder.tableId,
      'remainingCount': remainingProducts.length,
    });
    return true;
  }

  /// Lines still unpaid after extracting [selected] by identity.
  List<OrderProductObject> _remainingProducts({
    required List<OrderProductObject> original,
    required List<OrderProductObject> selected,
  }) {
    return [
      for (final product in original)
        if (!selected.any((s) => identical(s, product))) product,
    ];
  }

  CartState _buildPartialState({
    required OrderObject original,
    required List<OrderProductObject> selected,
  }) {
    final shell = OrderObject(
      products: selected,
      attributes: original.attributes,
      note: original.note,
      createdAt: CartState.timer(),
      tableId: original.tableId,
      pax: original.pax,
      employeeId: original.employeeId,
      shiftId: original.shiftId,
    );
    final state = CartState(name: 'split_bill');
    StashService.instance.restore(state, shell);
    // Preserve dine-in metadata even if menu lookup drops a line.
    state.tableId = original.tableId;
    state.pax = original.pax;
    state.note = original.note;
    return state;
  }

  Future<void> _reconcileStashAfterPayment({
    required OrderObject original,
    required List<OrderProductObject> remainingProducts,
  }) async {
    final stashId = original.id;
    if (stashId != null) {
      await StashedOrders.instance.delete(stashId);
    }

    final tableId = original.tableId;

    if (remainingProducts.isEmpty) {
      if (tableId != null) {
        try {
          await TableManagerService.instance.updateTableStatus(
            tableId,
            .available,
          );
        } catch (e, stack) {
          Log.err(e, 'split_bill_table_free_failed', stack);
          rethrow;
        }
      }
      return;
    }

    final remainingOrder = OrderObject(
      products: remainingProducts,
      attributes: original.attributes,
      note: original.note,
      createdAt: original.createdAt,
      tableId: original.tableId,
      pax: original.pax,
      employeeId: original.employeeId,
      shiftId: original.shiftId,
    );

    final remainingState = CartState(name: 'split_bill_remaining');
    StashService.instance.restore(remainingState, remainingOrder);
    remainingState.tableId = original.tableId;
    remainingState.pax = original.pax;
    remainingState.note = original.note;

    final stashed = await StashService.instance.stash(remainingState);
    if (!stashed) {
      throw StateError('Failed to stash remaining split-bill items');
    }
  }

  bool _isCommitted(CheckoutStatus status) {
    return status == .ok ||
        status == .cashierNotEnough ||
        status == .cashierUsingSmall;
  }
}
