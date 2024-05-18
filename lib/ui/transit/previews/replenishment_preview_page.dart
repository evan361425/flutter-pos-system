import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/replenishment.dart';
import 'package:possystem/translator.dart';

import 'preview_page.dart';

class ReplenishmentPreviewPage extends PreviewPage<Replenishment> {
  const ReplenishmentPreviewPage({
    super.key,
    required super.items,
  });

  @override
  Widget getItem(
    BuildContext context,
    Replenishment item,
  ) {
    return ExpansionTile(
      title: ImporterColumnStatus(
        name: item.name,
        status: item.statusName,
      ),
      subtitle: Text(S.stockReplenishmentMetaAffect(item.data.length)),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 8.0),
      children: _getData(context, item).toList(),
    );
  }

  Iterable<Widget> _getData(BuildContext context, Replenishment item) sync* {
    for (var entry in item.data.entries) {
      final ingredient = (Stock.instance.getItem(entry.key) ?? Stock.instance.getStaged(entry.key));
      final amount = (entry.value > 0 ? '+' : '') + entry.value.toString();

      yield MetaBlock.withString(context, [
        ingredient?.name ?? 'unknown',
        amount,
      ])!;
    }
  }
}
