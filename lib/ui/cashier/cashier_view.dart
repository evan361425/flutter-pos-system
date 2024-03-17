import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/style/route_circular_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

import 'widgets/unit_list_view.dart';

// every time push a new page, the page will rebuild, so cache the child widget
// ignore: must_be_immutable
class CashierView extends StatelessWidget {
  final int? tabIndex;

  Widget? child;

  CashierView({super.key, this.tabIndex});

  @override
  Widget build(BuildContext context) {
    return child ??= _build(context);
  }

  Widget _build(BuildContext context) {
    final tab = tabIndex == null
        ? null
        : TutorialInTab(index: tabIndex!, context: context);

    return TutorialWrapper(
      tab: tab,
      child: ListView(children: [
        const SizedBox(height: 4.0),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Tutorial(
            id: 'cashier.default',
            index: 2,
            title: S.orderCashierDefaultTutorialTitle,
            message: S.orderCashierDefaultTutorialMessage,
            child: RouteCircularButton(
              key: const Key('cashier.defaulter'),
              onTap: () => handleSetDefault(context),
              icon: Icons.upload_sharp,
              text: S.orderCashierDefaultButton,
            ),
          ),
          Tutorial(
            index: 1,
            id: 'cashier.change',
            title: S.orderCashierChangeTutorialTitle,
            message: S.orderCashierChangeTutorialMessage,
            child: RouteCircularButton(
              key: const Key('cashier.changer'),
              route: Routes.cashierChanger,
              icon: Icons.sync_alt_sharp,
              text: S.orderCashierChangeButton,
              popTrueShowSuccess: true,
            ),
          ),
          Tutorial(
            index: 0,
            id: 'cashier.surplus',
            title: S.orderCashierSurplusTutorialTitle,
            message: S.orderCashierSurplusTutorialMessage,
            child: RouteCircularButton(
              key: const Key('cashier.surplus'),
              icon: Icons.coffee_sharp,
              text: S.orderCashierSurplusButton,
              popTrueShowSuccess: true,
              onTap: () => handleSurplus(context),
            ),
          ),
        ]),
        const UnitListView(),
      ]),
    );
  }

  void handleSetDefault(BuildContext context) async {
    if (!Cashier.instance.defaultNotSet) {
      final result = await ConfirmDialog.show(
        context,
        title: '調整收銀臺預設？',
        content: '此動作將會覆蓋掉先前的設定。',
      );

      if (!result) {
        return;
      }
    }

    await Cashier.instance.setDefault();

    if (context.mounted) {
      showSnackBar(context, S.actSuccess);
    }
  }

  void handleSurplus(BuildContext context) async {
    if (Cashier.instance.defaultNotSet) {
      return showSnackBar(context, '尚未設定，請點選右上角「設為預設」');
    }

    final result = await context.pushNamed(Routes.cashierSurplus);
    if (result == true) {
      if (context.mounted) {
        showSnackBar(context, S.actSuccess);
      }
    }
  }
}
