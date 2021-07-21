import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/cashier/changer/changer_dialog.dart';
import 'package:possystem/ui/cashier/widgets/cashier_unit_list.dart';
import 'package:provider/provider.dart';

class CashierScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = Row(children: [
      Expanded(
        child: ElevatedButton(
          onPressed: () {},
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
        actions: [TextButton(onPressed: () {}, child: Text('設為預設'))],
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
      await context.showSuccessBar(content: Text(tt('success')));
    }
  }
}
