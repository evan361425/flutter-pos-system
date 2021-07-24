import 'package:flutter/material.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/cashier/changer/changer_dialog.dart';
import 'package:possystem/ui/cashier/widgets/cashier_surplus.dart';
import 'package:possystem/ui/cashier/widgets/cashier_unit_list.dart';
import 'package:provider/provider.dart';

class CashierScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final actions = Row(children: [
      Expanded(
        child: ElevatedButton(
          onPressed: () => handleSurplus(context),
          style: ElevatedButton.styleFrom(primary: theme.primaryColorLight),
          child: Text('結餘'),
        ),
      ),
      SizedBox(width: kSpacing1),
      Expanded(
        child: ElevatedButton(
          onPressed: () => handleChanging(context),
          child: Text('換錢'),
        ),
      ),
    ]);

    return Scaffold(
      appBar: AppBar(
        title: Text('收銀機'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(KIcons.back),
        ),
        actions: [
          TextButton(
            onPressed: () => handleSetDefault(context),
            child: Text('設為預設'),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(kSpacing3),
        child: Column(children: [
          actions,
          Divider(),
          Expanded(
            child: ChangeNotifierProvider.value(
              value: Cashier.instance,
              child: CashierUnitList(),
            ),
          ),
        ]),
      ),
    );
  }

  void handleChanging(BuildContext context) async {
    final success = await showDialog<bool>(
      context: context,
      builder: (_) => ChangerDialog(),
    );

    if (success == true) {
      showSuccessSnackbar(context, tt('success'));
    }
  }

  void handleSurplus(BuildContext context) async {
    if (Cashier.instance.defaultNotSet) {
      return showInfoSnackbar(context, '尚未設定，請點選右上角「設為預設」');
    }

    final success = await showDialog<bool>(
        context: context,
        builder: (_) => ConfirmDialog(
              title: '點選確認以結餘',
              content: CashierSurplus(),
            ));

    if (success == true) {
      await Cashier.instance.surplus();

      showSuccessSnackbar(context, tt('success'));
    }
  }

  void handleSetDefault(BuildContext context) async {
    if (!Cashier.instance.defaultNotSet) {
      final result = await showDialog(
          context: context,
          builder: (_) => ConfirmDialog(
                title: '確認通知',
                content: Text('將會覆蓋先前的設定\n此動作無法復原。'),
              ));

      if (result != true) {
        return;
      }
    }

    await Cashier.instance.setDefault(useCurrent: true);

    showSuccessSnackbar(context, tt('success'));
  }
}
