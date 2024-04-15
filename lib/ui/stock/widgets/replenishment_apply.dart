import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/style/card_info_text.dart';
import 'package:possystem/models/stock/replenishment.dart';
import 'package:possystem/translator.dart';

class ReplenishmentApply extends StatelessWidget {
  final Replenishment item;

  const ReplenishmentApply(this.item, {super.key});

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
            child: Text(S.stockReplenishmentApplyConfirmButton),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
        child: ListView(children: [
          CardInfoText(child: Text(S.stockReplenishmentApplyConfirmHint)),
          DataTable(columns: [
            DataColumn(label: Text(S.stockReplenishmentApplyConfirmColumn('name'))),
            DataColumn(numeric: true, label: Text(S.stockReplenishmentApplyConfirmColumn('amount')))
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
