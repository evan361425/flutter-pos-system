import 'package:flutter/material.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/style/appbar_text_button.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:simple_tip/simple_tip.dart';

import 'widgets/cashier_surplus.dart';
import 'widgets/cashier_unit_list.dart';

class CashierScreen extends StatelessWidget {
  final tipGrouper = GlobalKey<TipGrouperState>();

  final RouteObserver<ModalRoute<void>>? routeObserver;

  CashierScreen({Key? key, this.routeObserver}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final actions = Row(children: [
      Expanded(
        child: OrderedTip(
          id: 'surplus',
          grouper: tipGrouper,
          version: 1,
          order: 1,
          message: '結餘可以幫助你在每天打烊時，計算現有的金額和預設的金額差異。',
          child: ElevatedButton(
            key: const Key('cashier.surplus'),
            onPressed: () => handleSurplus(context),
            child: const Text('結餘'),
          ),
        ),
      ),
      const SizedBox(width: kSpacing1),
      Expanded(
        child: ElevatedButton(
          key: const Key('cashier.changer'),
          onPressed: () => handleChanging(context),
          child: const Text('換錢'),
        ),
      ),
    ]);

    return TipGrouper(
      key: tipGrouper,
      id: 'cashier',
      candidateLength: 2,
      routeObserver: routeObserver,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('收銀機'),
          leading: const PopButton(),
          actions: [
            OrderedTip(
              id: 'setDefault',
              grouper: tipGrouper,
              version: 1,
              order: 2,
              message: '設定完收銀機金額後，按這裡把設定後的金額設為「預設」',
              child: AppbarTextButton(
                key: const Key('cashier.defaulter'),
                onPressed: () => handleSetDefault(context),
                child: const Text('設為預設'),
              ),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(kSpacing3),
          child: Column(children: [
            actions,
            const Divider(),
            const Expanded(child: CashierUnitList()),
          ]),
        ),
      ),
    );
  }

  void handleChanging(BuildContext context) async {
    final success =
        await Navigator.of(context).pushNamed(Routes.cashierChanger);

    if (success == true) {
      showSuccessSnackbar(context, S.actSuccess);
    }
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

    final success = await showDialog<bool>(
        context: context,
        builder: (_) => const ConfirmDialog(
              title: '點選確認以結餘',
              content: CashierSurplus(),
            ));

    if (success == true) {
      await Cashier.instance.surplus();

      showSuccessSnackbar(context, S.actSuccess);
    }
  }
}
