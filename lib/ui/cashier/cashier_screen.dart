import 'package:flutter/material.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/style/route_circular_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:simple_tip/simple_tip.dart';

import 'widgets/cashier_unit_list.dart';

class CashierScreen extends StatelessWidget {
  final GlobalKey<TipGrouperState>? tipGrouper;

  final RouteObserver<ModalRoute<void>>? routeObserver;

  const CashierScreen({
    Key? key,
    this.routeObserver,
    this.tipGrouper,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TipGrouper(
      key: tipGrouper,
      id: 'cashier',
      candidateLength: 2,
      routeObserver: routeObserver,
      child: ListView(children: [
        const SizedBox(height: 4.0),
        Flex(direction: Axis.horizontal, children: [
          Expanded(
            child: OrderedTip(
              id: 'setDefault',
              grouper: tipGrouper,
              version: 1,
              order: 2,
              message: '設定完收銀機金額後，按這裡把設定後的金額設為「預設」',
              child: RouteCircularButton(
                key: const Key('cashier.defaulter'),
                onTap: () => handleSetDefault(context),
                icon: Icons.upload_outlined,
                text: '設為預設',
              ),
            ),
          ),
          const Expanded(
            child: RouteCircularButton(
              key: Key('cashier.changer'),
              route: Routes.cashierChanger,
              icon: Icons.sync_alt_outlined,
              text: '換錢',
              popTrueShowSuccess: true,
            ),
          ),
          Expanded(
            child: OrderedTip(
              id: 'surplus',
              grouper: tipGrouper,
              version: 1,
              order: 1,
              message: '結餘可以幫助你在每天打烊時，計算現有的金額和預設的金額差異。',
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
      final result = await showDialog(
          context: context,
          builder: (_) => const ConfirmDialog(
                title: '確認通知',
                content: Text('將會覆蓋先前的設定\n此動作無法復原。'),
              ));

      if (result != true) {
        return;
      }
    }

    await Cashier.instance.setDefault();

    showSuccessSnackbar(context, S.actSuccess);
  }

  void handleSurplus(BuildContext context) async {
    if (Cashier.instance.defaultNotSet) {
      return showInfoSnackbar(context, '尚未設定，請點選右上角「設為預設」');
    }

    final result = await Navigator.of(context).pushNamed(Routes.cashierSurplus);
    if (result == true) {
      showSuccessSnackbar(context, S.actSuccess);
    }
  }
}
