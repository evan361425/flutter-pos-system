import 'package:flutter/material.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/style/appbar_text_button.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/sliding_up_opener.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/order/cashier/cashier_calculator.dart';
import 'package:possystem/ui/order/cashier/cashier_quick_changer.dart';

import 'order_final_list.dart';

class OrderCalculatorModal extends StatefulWidget {
  const OrderCalculatorModal({Key? key}) : super(key: key);

  @override
  _OrderCalculatorModalState createState() => _OrderCalculatorModalState();
}

class _OrderCalculatorModalState extends State<OrderCalculatorModal> {
  final changer = GlobalKey<CashierQuickChangerState>();
  final calculator = GlobalKey<CashierCalculatorState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final totalPrice = Cart.instance.totalPrice;
    // 64*4 + 32 (padding)
    final panelMargin = (mediaQuery.size.width - 256 - 16 - 16) / 2;

    final panel = Container(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      margin: EdgeInsets.fromLTRB(panelMargin, 0, panelMargin, 16.0),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.all(Radius.circular(18.0)),
      ),
      child: CashierCalculator(
        key: calculator,
        onTextChanged: (value) =>
            changer.currentState?.paidChanged(num.tryParse(value)),
        onSubmit: handleSubmit,
        totalPrice: totalPrice,
      ),
    );

    final body = OrderFinalList();

    final collapsed = CashierQuickChanger(
      key: changer,
      totalPrice: totalPrice,
      onPaidChanged: (value) =>
          calculator.currentState?.text = value.toString(),
    );

    return Scaffold(
      appBar: AppBar(
        leading: PopButton(),
        title: Text('計算機'),
        actions: [
          AppbarTextButton(onPressed: handleSubmit, child: Text('結帳')),
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
        title: tt('order.cashier.confirm.leave_history'),
      ),
    );

    return result ?? false;
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