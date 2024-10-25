import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/dialog/responsive_dialog.dart';
import 'package:possystem/components/dialog/single_text_dialog.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/info_popup.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';

class CashierSurplus extends StatelessWidget {
  const CashierSurplus({super.key});

  @override
  Widget build(BuildContext context) {
    final cashier = context.watch<Cashier>();

    final columns = <DataColumn>[
      DataColumn(label: Text(S.cashierSurplusColumnName('unit')), numeric: true),
      DataColumn(label: Text(S.cashierSurplusColumnName('currentCount')), numeric: true),
      DataColumn(label: Text(S.cashierSurplusColumnName('diffCount'))),
      DataColumn(label: Text(S.cashierSurplusColumnName('defaultCount')), numeric: true),
    ];

    final rows = <DataRow>[
      for (final e in cashier.getDifference())
        DataRow(cells: <DataCell>[
          DataCell(Text(e.unit.toCurrency())),
          generateCell(e.currentCount, onTap: () => _handleTap(context, e)),
          generateCell(e.diffCount, withSign: true),
          generateCell(e.defaultCount),
        ]),
    ];

    return ResponsiveDialog(
      title: Text(S.cashierSurplusButton),
      action: TextButton(
        key: const Key('cashier_surplus.confirm'),
        onPressed: () async {
          await Cashier.instance.surplus();
          if (context.mounted && context.canPop()) {
            context.pop(true);
          }
        },
        child: Text(MaterialLocalizations.of(context).okButtonLabel),
      ),
      content: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _DataWithLabel(
            data: cashier.currentTotal.toCurrency(),
            label: S.cashierSurplusCurrentTotalLabel,
            helper: S.cashierSurplusCurrentTotalHelper,
          ),
          _DataWithLabel(
            data: (cashier.currentTotal - cashier.defaultTotal).toCurrency(),
            label: S.cashierSurplusDiffTotalLabel,
            helper: S.cashierSurplusDiffTotalHelper,
          ),
        ]),
        const Divider(),
        HintText(S.cashierSurplusTableHint, textAlign: TextAlign.center),
        const SizedBox(height: kInternalSpacing),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(columns: columns, rows: rows),
        ),
      ]),
    );
  }

  DataCell generateCell(
    int value, {
    bool withSign = false,
    VoidCallback? onTap,
  }) {
    return DataCell(
      Text(
        withSign ? '${value > 0 ? '+' : ''}$value' : value.toString(),
        textAlign: withSign ? TextAlign.left : TextAlign.right,
      ),
      showEditIcon: onTap != null,
      onTap: onTap,
    );
  }

  void _handleTap(BuildContext context, CashierDiffItem item) async {
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => SingleTextDialog(
        validator: Validator.positiveInt(S.cashierSurplusCounterShortLabel),
        keyboardType: TextInputType.number,
        selectAll: true,
        initialValue: item.currentCount.toString(),
        title: Text(S.cashierSurplusCounterLabel(item.unit.toCurrency())),
      ),
    );

    if (result is String) {
      final value = int.parse(result);
      await Cashier.instance.setCurrentByUnit(item.unit, value);
    }
  }
}

class _DataWithLabel extends StatelessWidget {
  final String data;

  final String label;

  final String? helper;

  const _DataWithLabel({
    required this.data,
    required this.label,
    this.helper,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(children: [
        Text(data, style: theme.textTheme.headlineSmall),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(label),
          if (helper != null) InfoPopup(helper!),
        ]),
      ]),
    );
  }
}
