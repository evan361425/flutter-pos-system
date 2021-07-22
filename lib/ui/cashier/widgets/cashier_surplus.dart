import 'package:flutter/material.dart';
import 'package:possystem/models/repository/cashier.dart';

class CashierSurplus extends StatelessWidget {
  const CashierSurplus({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('現有金'),
        Text(
          Cashier.instance.currentTotal.toString(),
          style: theme.textTheme.headline4,
        ),
      ]),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('初始金'),
        Text(Cashier.instance.defaultTotal.toString()),
      ]),
      Divider(),
      Table(
        border: TableBorder.all(),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: <TableRow>[
          TableRow(children: <Widget>[
            _TabelTextCell('金額'),
            _TabelTextCell('初始'),
            _TabelTextCell('差異'),
            _TabelTextCell('現有'),
          ]),
          for (var item in Cashier.instance.getDifference())
            TableRow(children: <Widget>[
              _TabelNumCell(item[0].unit),
              _TabelNumCell(item[1].count),
              _TabelNumCell(item[0].count - item[1].count, withSign: true),
              _TabelNumCell(item[0].count),
            ])
        ],
      ),
    ]);
  }
}

class _TabelNumCell extends StatelessWidget {
  final num value;

  final bool withSign;

  const _TabelNumCell(this.value, {this.withSign = false});

  @override
  Widget build(BuildContext context) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Text(
          withSign ? '${value > 0 ? '+' : ''}$value' : value.toString(),
          textAlign: TextAlign.right,
        ),
      ),
    );
  }
}

class _TabelTextCell extends StatelessWidget {
  final String value;

  const _TabelTextCell(this.value);

  @override
  Widget build(BuildContext context) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Text(value),
      ),
    );
  }
}
