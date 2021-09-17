import 'package:flutter/material.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/order/cashier/cashier_calculator.dart';
import 'package:possystem/ui/order/cashier/cashier_quick_changer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'order_final_list.dart';

class OrderCalculatorModal extends StatefulWidget {
  const OrderCalculatorModal({Key? key}) : super(key: key);

  @override
  _OrderCalculatorModalState createState() => _OrderCalculatorModalState();
}

class _OrderCalculatorModalState extends State<OrderCalculatorModal> {
  final changer = GlobalKey<CashierQuickChangerState>();

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.vertical(top: Radius.circular(8.0));
    final theme = Theme.of(context);
    final totalPrice = Cart.instance.totalPrice;

    final panel = Container(
      padding: const EdgeInsets.all(8.0),
      color: theme.scaffoldBackgroundColor,
      child: CashierCalculator(
        onTextChanged: handleCalculatorChanged,
        onSubmit: handleSubmit,
      ),
    );

    final collapsed = Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: borderRadius,
      ),
      child: CashierQuickChanger(
        key: changer,
        totalPrice: totalPrice,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: PopButton(),
        title: Text('計算機'),
        actions: [
          TextButton(onPressed: handleSubmit, child: Text('結帳')),
        ],
      ),
      body: SlidingUpPanel(
        color: Colors.transparent,
        backdropEnabled: true,
        // 4 rows * 32 + 16 (padding)
        maxHeight: 144,
        borderRadius: borderRadius,
        body: OrderFinalList(),
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
        title: tt('order.cashier.confirm.leave_history'),
      ),
    );

    return result ?? false;
  }

  void handleCalculatorChanged(String value) {
    changer.currentState?.paidChanged(num.tryParse(value));
  }

  void handleSubmit() async {
    if (!await confirmChangeHistory()) {
      return;
    }

    try {
      await Cart.instance.paid(changer.currentState?.selected);
      // send success message
      Navigator.of(context).pop(true);
    } catch (e) {
      if (e == 'too low') {
        showErrorSnackbar(context, tt('order.cashier.error.low_paid'));
      } else {
        showErrorSnackbar(context, e.toString());
      }
    }
  }
}
