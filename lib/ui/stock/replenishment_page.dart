import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/slidable_item_list.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/stock/replenishment.dart';
import 'package:possystem/routes.dart';
import 'package:provider/provider.dart';

import 'package:possystem/translator.dart';

class ReplenishmentPage extends StatelessWidget {
  const ReplenishmentPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final replenisher = context.watch<Replenisher>();

    void handleCreate() => context.pushNamed(Routes.replenishmentNew);

    final body = replenisher.isEmpty
        ? Center(
            child: EmptyBody(
            onPressed: handleCreate,
            tooltip: '採購可以幫你快速調整成分的庫存',
          ))
        : SlidableItemList<Replenishment, int>(
            delegate: SlidableItemDelegate(
              groupTag: 'stock.replenishment',
              handleDelete: (item) => item.remove(),
              deleteValue: 1,
              warningContextBuilder: (_, item) =>
                  Text(S.dialogDeletionContent(item.name, '')),
              items: replenisher.itemList,
              tileBuilder: (_, index, item, __) => _ReplenishmentTile(item),
            ),
          );

    return Scaffold(
      appBar: AppBar(
        title: Text(S.stockReplenishmentTitle),
        leading: const PopButton(),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('replenisher.add'),
        onPressed: handleCreate,
        tooltip: S.stockReplenishmentCreate,
        child: const Icon(KIcons.add),
      ),
      body: body,
    );
  }
}

class _ReplenishmentTile extends StatelessWidget {
  final Replenishment item;

  const _ReplenishmentTile(this.item);

  @override
  Widget build(BuildContext context) {
    return ListTile(
        key: Key('replenisher.${item.id}'),
        title: Text(item.name),
        subtitle: Text(S.stockReplenishmentSubtitle(item.data.length)),
        onTap: () => context.pushNamed(
              Routes.replenishmentModal,
              pathParameters: {'id': item.id},
            ),
        trailing: TextButton(
          key: Key('replenisher.${item.id}.apply'),
          onPressed: () => handleApply(context),
          child: const Text('套用'),
        ));
  }

  Future<void> handleApply(BuildContext context) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: S.stockReplenishmentApplyConfirmTitle(item.name),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(S.stockReplenishmentApplyConfirmContent),
          const SizedBox(height: kSpacing1),
          DataTable(columns: const [
            DataColumn(label: Text('名稱')),
            DataColumn(numeric: true, label: Text('數量'))
          ], rows: <DataRow>[
            for (final entry in item.ingredientData.entries)
              DataRow(cells: [
                DataCell(Text(entry.key.name)),
                DataCell(Text(entry.value.toString())),
              ])
          ]),
        ],
      ),
    );

    if (confirmed) {
      await item.apply();
      if (context.mounted && context.canPop()) {
        context.pop(true);
      }
    }
  }
}
