import 'package:flutter/material.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/sliding_up_opener.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/translator.dart';

import 'order_cashier_calculator.dart';
import 'order_cashier_product_list.dart';
import 'order_cashier_snapshot.dart';

class OrderCashierModal extends StatelessWidget {
  final calculator = GlobalKey<OrderCashierCalculatorState>();

  OrderCashierModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalPrice = Cart.instance.totalPrice;

    final collapsed = OrderCashierSnapshot(
      totalPrice: totalPrice,
      onPaidChanged: (value) =>
          calculator.currentState?.text = value.toString(),
    );

    void handleSubmit() async {
      // ignore: use_build_context_synchronously
      if (await _confirmChangeHistory(context)) {
        try {
          final result = await Cart.instance
              .paid(collapsed.selector.currentState?.selected);
          // send success message
          if (context.mounted) {
            Navigator.of(context).pop(result);
          }
        } on PaidException {
          if (context.mounted) {
            showErrorSnackbar(context, S.orderCashierCalculatorChangeNotEnough);
          }
        }
      }
    }

    final panel = Container(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      margin: const EdgeInsets.fromLTRB(4.0, 0, 4.0, 16.0),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(18.0)),
      ),
      child: OrderCashierCalculator(
        key: calculator,
        onTextChanged: (value) => collapsed.paidChanged(value),
        onSubmit: handleSubmit,
        totalPrice: totalPrice,
      ),
    );

    final body = OrderCashierProductList(
      attributes: Cart.instance.selectedAttributeOptions
          .map((e) => OrderSelectedAttributeObject.fromModel(e))
          .toList(),
      products: Cart.instance.products
          .map((e) => OrderProductTileData(
                product: e.product,
                productName: e.name,
                ingredientNames: e.getIngredientNames(onlyQuantified: false),
                totalPrice: e.price,
                totalCount: e.count,
              ))
          .toList(),
      totalPrice: totalPrice,
      productsPrice: Cart.instance.productsPrice,
    );

    return Scaffold(
      appBar: AppBar(
        leading: const PopButton(),
        title: Text(S.orderCashierTitle),
        actions: [
          TextButton(
            key: const Key('cashier.order'),
            onPressed: handleSubmit,
            child: Text(S.orderCashierActionsOrder),
          ),
        ],
      ),
      body: SlidingUpOpener(
        // 4 rows * 64 + 24 (insets) + 64 (collapse)
        maxHeight: 408,
        minHeight: 84,
        renderPanelSheet: false,
        body: body,
        panel: panel,
        collapsed: collapsed,
      ),
    );
  }

  /// Confirm leaving history mode
  Future<bool> _confirmChangeHistory(BuildContext context) async {
    if (!Cart.instance.isHistoryMode) return true;

    final result = await showDialog(
      context: context,
      builder: (_) => ConfirmDialog(
        title: S.orderCashierPaidConfirmLeaveHistoryMode,
      ),
    );

    return result ?? false;
  }
}
