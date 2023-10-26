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

class CashierView extends StatelessWidget {
  final TutorialInTab? tab;

  const CashierView({Key? key, this.tab}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TutorialWrapper(
      tab: tab,
      child: ListView(children: [
        const SizedBox(height: 4.0),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Tutorial(
            id: 'cashier.default',
            index: 2,
            title: '收銀機預設狀態',
            message: '在下面設定完收銀機各幣值的數量後，\n'
                '按這裡設定預設狀態！\n'
                '設定好的數量就會是各個幣值狀態條的「最大值」。',
            child: RouteCircularButton(
              key: const Key('cashier.defaulter'),
              onTap: () => handleSetDefault(context),
              icon: Icons.upload_sharp,
              text: '設為預設',
            ),
          ),
          const Tutorial(
            index: 1,
            id: 'cashier.change',
            title: '收銀機換錢',
            message: '一百塊換成 10 個十塊之類。\n' '幫助快速調整收銀機狀態。',
            child: RouteCircularButton(
              key: Key('cashier.changer'),
              route: Routes.cashierChanger,
              icon: Icons.sync_alt_sharp,
              text: '換錢',
              popTrueShowSuccess: true,
            ),
          ),
          Tutorial(
            index: 0,
            id: 'cashier.surplus',
            title: '每日結餘',
            message: '結餘可以幫助我們在每天打烊時，\n' '計算現有金額和預設金額的差異。',
            child: RouteCircularButton(
              key: const Key('cashier.surplus'),
              icon: Icons.coffee_sharp,
              text: '結餘',
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
