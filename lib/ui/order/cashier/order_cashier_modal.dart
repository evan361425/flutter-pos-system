import 'package:flutter/material.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/style/appbar_text_button.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/sliding_up_opener.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/translator.dart';

import 'order_cashier_calculator.dart';
import 'order_cashier_product_list.dart';
import 'order_cashier_snapshot.dart';

class OrderCashierModal extends StatefulWidget {
  const OrderCashierModal({Key? key}) : super(key: key);

  @override
  _OrderCashierModalState createState() => _OrderCashierModalState();
}

class _OrderCashierModalState extends State<OrderCashierModal> {
  final snapshot = GlobalKey<OrderCashierSnapshotState>();
  final calculator = GlobalKey<OrderCashierCalculatorState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalPrice = Cart.instance.totalPrice;

    final panel = Container(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      margin: const EdgeInsets.fromLTRB(4.0, 0, 4.0, 16.0),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(18.0)),
      ),
      child: OrderCashierCalculator(
        key: calculator,
        onTextChanged: (value) =>
            snapshot.currentState?.paidChanged(num.tryParse(value)),
        onSubmit: handleSubmit,
        totalPrice: totalPrice,
      ),
    );

    final body = OrderCashierProductList(
      customerSettings: Cart.instance.selectedCustomerSettingOptions.toList(),
      products: Cart.instance.products
          .map((e) => OrderProductTileData(
                ingredientNames: e.getIngredientNames(onlyQuantitied: false),
                productName: e.name,
                totalPrice: e.price,
                totalCount: e.count,
              ))
          .toList(),
      totalPrice: totalPrice,
      productsPrice: Cart.instance.productsPrice,
    );

    final collapsed = OrderCashierSnapshot(
      key: snapshot,
      totalPrice: totalPrice,
      onPaidChanged: (value) =>
          calculator.currentState?.text = value.toString(),
    );

    return Scaffold(
      appBar: AppBar(
        leading: const PopButton(),
        title: Text(S.orderCashierTitle),
        actions: [
          AppbarTextButton(
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
  Future<bool> confirmChangeHistory() async {
    if (!Cart.instance.isHistoryMode) return true;

    final result = await showDialog(
      context: context,
      builder: (_) => ConfirmDialog(
        title: S.orderCashierPaidConfirmLeaveHistoryMode,
      ),
    );

    return result ?? false;
  }

  void handleSubmit() async {
    if (!await confirmChangeHistory()) {
      return;
    }

    try {
      final success = await Cart.instance.paid(snapshot.currentState?.selected);
      // send success message
      Navigator.of(context).pop(success);
    } on PaidException {
      showErrorSnackbar(context, S.orderCashierCalculatorChangeNotEnough);
    } catch (err, stack) {
      showErrorSnackbar(context, S.actError);
      error(err.toString(), 'order.error', stack);
    }
  }
}
