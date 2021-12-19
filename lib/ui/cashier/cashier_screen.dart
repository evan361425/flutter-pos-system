import 'package:flutter/material.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/style/route_tile.dart';
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
      child: Scaffold(
        body: Column(children: [
          OrderedTip(
            id: 'surplus',
            grouper: tipGrouper,
            version: 1,
            order: 1,
            message: '結餘可以幫助你在每天打烊時，計算現有的金額和預設的金額差異。',
            child: RouteTile(
              key: const Key('cashier.surplus'),
              route: Routes.cashierSurplus,
              icon: Icons.coffee_outlined,
              title: '結餘',
              popTrueShowSuccess: true,
              preCheck: () =>
                  Cashier.instance.defaultNotSet ? '尚未設定，請點選右上角「設為預設」' : null,
            ),
          ),
          const RouteTile(
            key: Key('cashier.changer'),
            route: Routes.cashierChanger,
            icon: Icons.sync_alt_outlined,
            title: '換錢',
            popTrueShowSuccess: true,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: OrderedTip(
              id: 'setDefault',
              grouper: tipGrouper,
              version: 1,
              order: 2,
              message: '設定完收銀機金額後，按這裡把設定後的金額設為「預設」',
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: OutlinedButton(
                  key: const Key('cashier.defaulter'),
                  onPressed: () => handleSetDefault(context),
                  child: const Text('設為預設'),
                ),
              ),
            ),
          ),
          const Expanded(child: CashierUnitList()),
        ]),
      ),
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
}
