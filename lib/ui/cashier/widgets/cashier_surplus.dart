import 'package:flutter/material.dart';
import 'package:info_popup/info_popup.dart';
import 'package:possystem/components/dialog/single_text_dialog.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:provider/provider.dart';

class CashierSurplus extends StatelessWidget {
  const CashierSurplus({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cashier = context.watch<Cashier>();

    const columns = <DataColumn>[
      DataColumn(label: Text('單位'), numeric: true),
      DataColumn(label: Text('現有'), numeric: true),
      DataColumn(label: Text('差異')),
      DataColumn(label: Text('預設'), numeric: true),
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

    return Scaffold(
      appBar: AppBar(
        leading: const PopButton(),
        title: const Text('結餘'),
        actions: [
          TextButton(
            key: const Key('cashier_surplus.confirm'),
            onPressed: () async {
              await Cashier.instance.surplus();
              if (context.mounted) {
                Navigator.of(context).pop(true);
              }
            },
            child: const Text('完成'),
          ),
        ],
      ),
      body: Column(children: [
        _DataWithLabel(
          data: cashier.currentTotal.toCurrency(),
          label: '現有總額',
          helper: '現在收銀機應該要有的總額\n若你發現現金和這值對不上，想一想今天有沒有用收銀機的錢買東西？',
        ),
        _DataWithLabel(
          data: (cashier.currentTotal - cashier.defaultTotal).toCurrency(),
          label: '差額',
          helper: '和收銀機最一開始的總額的差額\n這可以快速幫你了解今天收銀機多了多少錢唷。',
        ),
        const Divider(),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: HintText(
            '若你確認收銀機的金錢都沒問題之後就可以完成結餘囉！',
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(columns: columns, rows: rows),
              ),
            ),
          ),
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
        validator: Validator.positiveInt('數量'),
        keyboardType: TextInputType.number,
        selectAll: true,
        initialValue: item.currentCount.toString(),
        title: Text('幣值${item.unit.toCurrency()}的數量'),
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
    Key? key,
    required this.data,
    required this.label,
    this.helper,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(children: [
        Text(data, style: theme.textTheme.headlineSmall),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(label),
          if (helper != null)
            InfoPopupWidget(
              contentTitle: helper!,
              child: const Icon(Icons.help_outline_sharp, size: 16.0),
            ),
        ]),
      ]),
    );
  }
}
