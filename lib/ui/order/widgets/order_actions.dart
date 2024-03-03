import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/style/more_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

class OrderActions extends StatelessWidget {
  const OrderActions({super.key});

  @override
  Widget build(BuildContext context) {
    return MoreButton(
      onPressed: () async {
        final result = await showCircularBottomSheet<OrderAction>(
          context,
          actions: [
            BottomSheetAction(
              key: const Key('order.action.changer'),
              title: Text(S.orderActionsOpenChanger),
              leading: const Icon(Icons.change_circle_sharp),
              returnValue: const OrderAction(route: Routes.cashierChanger),
            ),
            BottomSheetAction(
              key: const Key('order.action.stash'),
              title: Text(S.orderActionsStash),
              leading: const Icon(Icons.file_download_sharp),
              returnValue: OrderAction(action: () => _stash(context)),
            ),
            const BottomSheetAction(
              key: Key('order.action.history'),
              title: Text('訂單記錄'),
              leading: Icon(Icons.history_sharp),
              returnValue: OrderAction(route: Routes.history),
            ),
          ],
        );

        if (context.mounted && result != null) {
          final success = await result.exec(context);

          if (success == true && context.mounted) {
            showSnackBar(context, S.actSuccess);
          }
        }
      },
    );
  }

  Future<bool?> _stash(BuildContext context) {
    DraggableScrollableActuator.reset(context);
    return Cart.instance.stash();
  }
}

class OrderAction {
  final Future<bool?> Function()? action;

  final String? route;

  const OrderAction({this.action, this.route});

  Future<bool?> exec(BuildContext context) {
    return route == null ? action!() : context.pushNamed(route!);
  }
}
