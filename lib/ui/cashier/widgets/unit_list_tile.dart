import 'package:flutter/material.dart';
import 'package:possystem/components/dialog/slider_text_dialog.dart';
import 'package:possystem/components/style/percentile_bar.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/objects/cashier_object.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/translator.dart';

class UnitListTile extends StatelessWidget {
  final CashierUnitObject item;
  final int index;

  const UnitListTile({
    super.key,
    required this.item,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final max = Cashier.instance.defaultAt(index)?.count ?? 0;
    return ListTile(
      title: Text(S.cashierUnitLabel(item.unit.toCurrencyLong())),
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
