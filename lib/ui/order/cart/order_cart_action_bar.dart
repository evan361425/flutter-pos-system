import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/routes/app_route_names.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';

/// Bottom action bar: Fire / Stash + Pay, with large touch targets for till use.
class OrderCartActionBar extends StatelessWidget {
  static const double buttonHeight = 64;

  final VoidCallback? onCheckout;

  const OrderCartActionBar({super.key, this.onCheckout});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<Cart>();
    final canAct = !cart.isEmpty;
    final isDineIn = cart.tableId != null;
    final fireLabel = isDineIn
        ? S.orderActionSendToKitchen
        : S.orderActionStash;

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: buttonHeight,
              child: FilledButton.tonalIcon(
                key: const Key('order.action.fire'),
                onPressed: canAct ? () => _handleFire(context, cart) : null,
                icon: Icon(
                  isDineIn ? Icons.restaurant_outlined : Icons.archive_outlined,
                ),
                label: Text(
                  fireLabel,
                  style: const TextStyle(fontSize: 16, fontWeight: .w600),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: buttonHeight,
              child: FilledButton.icon(
                key: const Key('order.checkout'),
                onPressed: canAct ? onCheckout : null,
                icon: const Icon(Icons.payments_outlined),
                label: Text(
                  S.orderActionCheckout,
                  style: const TextStyle(fontSize: 16, fontWeight: .w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleFire(BuildContext context, Cart cart) async {
    final wasDineIn = cart.tableId != null;
    final ok = await cart.stash();
    if (!context.mounted) return;

    if (ok) {
      showSnackBar(S.actSuccess, context: context);
      if (wasDineIn) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(AppRouteNames.path(AppRouteNames.floorPlan));
        }
      }
    }
  }
}
