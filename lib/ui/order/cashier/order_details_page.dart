import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/translator.dart';

import 'order_cashier_view.dart';
import 'order_setting_view.dart';

class OrderDetailsPage extends StatefulWidget {
  const OrderDetailsPage({Key? key}) : super(key: key);

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;

  late final bool hasAttr;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const PopButton(),
        actions: [
          TextButton(
            key: const Key('order.checkout'),
            onPressed: onCheckout,
            child: Text(S.orderCashierCheckout),
          ),
        ],
        // disable shadow after scrolled
        scrolledUnderElevation: 0,
        bottom: TabBar(
          controller: _controller,
          tabs: [
            if (hasAttr)
              Tab(
                  key: const Key('order.set_attr'),
                  text: S.orderSetAttributeTitle),
            Tab(key: const Key('order.cashier'), text: S.orderCashierTitle),
          ],
        ),
      ),
      body: TabBarView(controller: _controller, children: [
        if (hasAttr) const OderSettingView(),
        const OrderCashierView(),
      ]),
    );
  }

  @override
  void initState() {
    super.initState();

    hasAttr = OrderAttributes.instance.hasNotEmptyItems;
    final setBefore = hasAttr && Cart.instance.attributes.isNotEmpty;

    _controller = TabController(
      initialIndex: setBefore ? 1 : 0,
      length: hasAttr ? 2 : 1,
      vsync: this,
    );
  }

  void onCheckout() async {
    if (context.mounted) {
      final confirmed = await _confirmChangeHistory(context);
      if (confirmed) {
        try {
          final result = await Cart.instance.checkout();
          // send success message
          if (context.mounted && context.canPop()) {
            context.pop(result);
          }
        } on PaidException {
          if (context.mounted) {
            showSnackBar(context, S.orderCashierPaidFailed);
          }
        }
      }
    }
  }

  /// Confirm leaving history mode
  Future<bool> _confirmChangeHistory(BuildContext context) async {
    if (!Cart.instance.isHistoryMode) return true;

    return await ConfirmDialog.show(
      context,
      title: S.orderCashierPaidConfirmLeaveHistoryMode,
    );
  }
}
