import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/style/card_info_text.dart';
import 'package:possystem/models/stock/replenishment.dart';

class ReplenishmentApply extends StatelessWidget {
  final Replenishment item;

  const ReplenishmentApply(this.item, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
        actions: [
          TextButton(
            key: const Key('repl.apply'),
            onPressed: () async {
              await item.apply();
              if (context.mounted && context.canPop()) {
                context.pop(true);
              }
            },
            child: const Text('套用'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
        child: ListView(children: [
          const CardInfoText(child: Text('選擇套用後，將會影響以下成分的庫存')),
          DataTable(columns: const [
            DataColumn(label: Text('名稱')),
            DataColumn(numeric: true, label: Text('數量'))
          ], rows: <DataRow>[
            for (final entry in item.ingredientData.entries)
              DataRow(cells: [
                DataCell(Text(entry.key.name)),
                DataCell(Text(entry.value.toString())),
              ]),
          ]),
        ]),
      ),
    );
  }
}
