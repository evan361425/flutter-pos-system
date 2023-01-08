import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/helpers/formatter/formatter.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/ui/exporter/previews/previewer_screen.dart';

class IngredientPreviewer extends PreviewerScreen<Ingredient> {
  const IngredientPreviewer({
    Key? key,
    required List<FormattedItem> items,
  }) : super(key: key, items: items);

  @override
  Widget getItem(BuildContext context, Ingredient item) {
    return ListTile(
      title: ImporterColumnStatus(
        name: item.name,
        status: item.statusName,
      ),
      subtitle: MetaBlock.withString(context, <String>[
        '庫存：${item.currentAmount}',
      ]),
    );
  }

  @override
  Widget getHeader(BuildContext context) {
    return const Text('匯入後，為了避免影響「菜單」的狀況，並不會把舊的成分移除。');
  }
}
