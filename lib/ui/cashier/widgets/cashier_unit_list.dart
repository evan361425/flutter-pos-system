import 'package:flutter/material.dart';
import 'package:possystem/components/dialog/single_text_dialog.dart';
import 'package:possystem/components/style/icon_filled_button.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:provider/provider.dart';

class CashierUnitList extends StatelessWidget {
  const CashierUnitList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cashier = context.watch<Cashier>();

    return ListView.builder(
      itemBuilder: (_, i) {
        final unit = cashier.at(i);

        return ListTile(
          title: Text('幣值：${unit.unit}'),
          subtitle: Text(
            '數量：${unit.count}',
            key: Key('cashier.${unit.unit}.count'),
          ),
          trailing: Wrap(
            spacing: kSpacing1,
            children: <Widget>[
              IconFilledButton(
                key: Key('cashier.${unit.unit}.plus'),
                onPressed: () => handlePlus(context, i),
                icon: KIcons.add,
                type: IconFilledButtonType.outlined,
              ),
              IconFilledButton(
                key: Key('cashier.${unit.unit}.minus'),
                onPressed: () => handleMinus(context, i),
                icon: KIcons.remove,
                type: IconFilledButtonType.outlined,
              ),
            ],
          ),
        );
      },
      itemCount: cashier.unitLength,
    );
  }

  void handlePlus(BuildContext context, int index) async {
    final count = await waitForInput(context, '欲新增的數量');
    if (count != null) {
      await Cashier.instance.plus(index, count);
    }
  }

  void handleMinus(BuildContext context, int index) async {
    final count = await waitForInput(context, '欲減少的數量');
    if (count != null) {
      await Cashier.instance.minus(index, count);
    }
  }

  Future<int?> waitForInput(BuildContext context, String title) async {
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => SingleTextDialog(
        title: Text(title),
        validator: Validator.positiveInt('數量'),
        initialValue: '1',
        keyboardType: TextInputType.number,
      ),
    );

    return result == null ? null : int.tryParse(result);
  }
}
