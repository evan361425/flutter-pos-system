import 'package:flutter/material.dart';
import 'package:possystem/components/dialog/slider_text_dialog.dart';
import 'package:possystem/components/style/percentile_bar.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/objects/cashier_object.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';

class UnitListView extends StatelessWidget {
  const UnitListView({super.key});

  @override
  Widget build(BuildContext context) {
    final cashier = context.watch<Cashier>();
    int i = 0;

    return Column(children: [
      for (final item in cashier.currentUnits) _itemWidget(context, item, i++),
    ]);
  }

  Widget _itemWidget(BuildContext context, CashierUnitObject item, int index) {
    final max = Cashier.instance.defaultAt(index)?.count ?? 0;
    return ListTile(
      title: Text(S.cashierUnitLabel(item.unit.toCurrency())),
      subtitle: PercentileBar(item.count, max),
      onTap: () => _setUnitCount(context, item.unit, max, item.count),
    );
  }

  Future<void> _setUnitCount(
    BuildContext context,
    num unit,
    num max,
    int value,
  ) async {
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => SliderTextDialog(
        value: value,
        max: max.toDouble(),
        title: Text(S.cashierUnitLabel(unit.toCurrency())),
        validator: Validator.positiveInt(S.cashierCounterLabel),
        decoration: InputDecoration(label: Text(S.cashierCounterLabel)),
      ),
    );

    if (result != null) {
      await Cashier.instance.setUnitCount(unit, int.tryParse(result) ?? 0);
    }
  }
}
