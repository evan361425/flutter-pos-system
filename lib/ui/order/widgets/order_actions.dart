import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/style/more_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

class OrderActions extends StatelessWidget {
  const OrderActions({Key? key}) : super(key: key);

  List<BottomSheetAction<OrderActionMode>> get actions {
    return [
      BottomSheetAction(
        key: const Key('order.action.changer'),
        title: Text(S.orderActionsOpenChanger),
        leading: const Icon(Icons.change_circle_sharp),
        returnValue: OrderActionMode.changer,
      ),
      BottomSheetAction(
        key: const Key('order.action.stash'),
        title: Text(S.orderActionsStash),
        leading: const Icon(Icons.file_download_sharp),
        returnValue: OrderActionMode.stash,
      ),
      const BottomSheetAction(
        key: Key('order.action.history'),
        title: Text('訂單記錄'),
        leading: Icon(Icons.history_sharp),
        returnValue: OrderActionMode.history,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MoreButton(
      onPressed: () async {
        final result = await showCircularBottomSheet<OrderActionMode>(
          context,
          actions: actions,
        );

        if (context.mounted) {
          final success = await exec(context, result);

          if (success == true && context.mounted) {
            showSnackBar(context, S.actSuccess);
          }
        }
      },
    );
  }

  Future<bool?> exec(BuildContext context, OrderActionMode? action) async {
    switch (action) {
      case OrderActionMode.stash:
        return Cart.instance.stash();
      case OrderActionMode.changer:
        return context.pushNamed(Routes.cashierChanger);
      case OrderActionMode.history:
        return context.pushNamed(Routes.history);
      default:
        return false;
    }
  }
}

enum OrderActionMode {
  changer,
  stash,
  history,
}
