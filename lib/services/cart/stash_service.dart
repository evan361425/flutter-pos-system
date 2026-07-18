import 'dart:async';

import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/stashed_orders.dart';
import 'package:possystem/models/tables/table_status.dart';
import 'package:possystem/services/cart/cart_state.dart';
import 'package:possystem/services/cart/cart_state_manager.dart';
import 'package:possystem/services/cart/receipt_service.dart';
import 'package:possystem/services/tables/table_manager_service.dart';

/// Service responsible for stashing and restoring orders.
class StashService {
  static final StashService instance = StashService._();

  StashService._();

  /// Stash order to restore later.
  ///
  /// When the cart is bound to a dining table, any previous stash row for that
  /// table is replaced (single open check per table), then the table becomes
  /// [TableStatus.occupied] after a successful local write.
  ///
  /// After a successful local stash, kitchen tickets are fired in the
  /// background ([kitchenOnly]) so a printer failure never blocks the till.
  Future<bool> stash(CartState state) async {
    final able = !state.isEmpty;

    if (able) {
      // Snapshot before clear — tickets must not see an emptied cart.
      final stashedOrder = state.toObject();
      final tableId = state.tableId;

      if (tableId != null) {
        try {
          final existing = await StashedOrders.instance.getByTableId(tableId);
          if (existing?.id != null) {
            await StashedOrders.instance.delete(existing!.id!);
          }
        } catch (e, stack) {
          Log.err(e, 'stash_replace_failed', stack);
        }
      }

      await StashedOrders.instance.stash(stashedOrder);

      if (tableId != null) {
        try {
          await TableManagerService.instance.updateTableStatus(
            tableId,
            TableStatus.occupied,
          );
        } catch (e, stack) {
          Log.err(e, 'table_occupy_failed', stack);
        }
      }

      unawaited(_dispatchKitchen(stashedOrder));

      CartStateManager.instance.clear(state);
    }

    return able;
  }

  /// Fire kitchen printers only; never rethrow to the stash caller.
  Future<void> _dispatchKitchen(OrderObject order) async {
    try {
      await ReceiptService.instance.dispatchOrder(order, kitchenOnly: true);
    } catch (e, stack) {
      Log.err(e, 'stash_kitchen_dispatch_failed', stack);
    }
  }

  /// Restore the order into [state], including dine-in [tableId] / [pax].
  void restore(CartState state, OrderObject order) {
    state.products
      ..clear()
      ..addAll(order.productModels);
    state.attributes
      ..clear()
      ..addAll(order.selectedAttributes);
    state.selectedProduct.value = null;
    state.note = order.note;
    state.tableId = order.tableId;
    state.pax = order.pax;
    state.stashId = order.id;
  }
}
