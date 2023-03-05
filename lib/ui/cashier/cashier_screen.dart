import 'package:flutter/material.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/style/route_circular_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

import 'widgets/cashier_unit_list.dart';

class CashierScreen extends StatelessWidget {
  final TutorialInTab? tab;

  const CashierScreen({Key? key, this.tab}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TutorialWrapper(
      startWhenReady: false,
      child: ListView(children: [
        const SizedBox(height: 4.0),
        Flex(direction: Axis.horizontal, children: [
          Expanded(
            child: Tutorial(
              id: 'cashier.default',
              index: 2,
              tab: tab,
              title: '收銀機預設狀態',
              message: '在下面設定完收銀機各幣值的數量後，\n'
                  '按這裡設定預設狀態！\n'
                  '設定好的數量就會是各個幣值狀態條的「最大值」。',
              child: RouteCircularButton(
                key: const Key('cashier.defaulter'),
                onTap: () => handleSetDefault(context),
                icon: Icons.upload_outlined,
                text: '設為預設',
              ),
            ),
          ),
          const Expanded(
            child: Tutorial(
              index: 1,
              id: 'cashier.change',
              title: '收銀機換錢',
              message: '一百塊換成 10 個十塊之類。\n' '幫助快速調整收銀機狀態。',
              child: RouteCircularButton(
                key: Key('cashier.changer'),
                route: Routes.cashierChanger,
                icon: Icons.sync_alt_outlined,
                text: '換錢',
                popTrueShowSuccess: true,
              ),
            ),
          ),
          Expanded(
            child: Tutorial(
              index: 0,
              id: 'cashier.surplus',
              title: '每日結餘',
              message: '結餘可以幫助我們在每天打烊時，\n' '計算現有金額和預設金額的差異。',
              child: RouteCircularButton(
                key: const Key('cashier.surplus'),
                icon: Icons.coffee_outlined,
                text: '結餘',
                popTrueShowSuccess: true,
                onTap: () => handleSurplus(context),
              ),
            ),
          ),
        ]),
        const CashierUnitList(),
      ]),
    );
  }

  void handleSetDefault(BuildContext context) async {
    if (!Cashier.instance.defaultNotSet) {
      final result = await ConfirmDialog.show(
        context,
        title: '確認通知',
        content: '將會覆蓋先前的設定\n此動作無法復原。',
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

    final result = await Navigator.of(context).pushNamed(Routes.cashierSurplus);
    if (result == true) {
      if (context.mounted) {
        showSnackBar(context, S.actSuccess);
      }
    }
  }
}
