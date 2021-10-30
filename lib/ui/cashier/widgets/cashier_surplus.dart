import 'package:flutter/material.dart';
import 'package:possystem/models/repository/cashier.dart';

class CashierSurplus extends StatelessWidget {
  const CashierSurplus({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('現有金'),
        Text(
          Cashier.instance.currentTotal.toString(),
          style: theme.textTheme.headline4,
        ),
      ]),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('初始金'),
        Text(Cashier.instance.defaultTotal.toString()),
      ]),
      const Divider(),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const <DataColumn>[
            DataColumn(label: Text('金額'), numeric: true),
            DataColumn(label: Text('初始'), numeric: true),
            DataColumn(label: Text('差異'), numeric: true),
            DataColumn(label: Text('現有'), numeric: true),
          ],
          rows: <DataRow>[
            for (var item in Cashier.instance.getDifference())
              DataRow(cells: <DataCell>[
                generateCell(item[0].unit),
                generateCell(item[1].count),
                generateCell(item[0].count - item[1].count, withSign: true),
                generateCell(item[0].count),
              ])
          ],
        ),
      ),
    ]);
  }

  DataCell generateCell(num value, {bool withSign = false}) {
    return DataCell(Text(
      withSign ? '${value > 0 ? '+' : ''}$value' : value.toString(),
      textAlign: TextAlign.right,
    ));
  }
}
