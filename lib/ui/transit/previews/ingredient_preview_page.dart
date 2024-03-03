import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/models/stock/ingredient.dart';

import 'preview_page.dart';

class IngredientPreviewPage extends PreviewPage<Ingredient> {
  const IngredientPreviewPage({
    super.key,
    required super.items,
  });

  @override
  Widget getItem(BuildContext context, Ingredient item) {
    return ListTile(
      title: ImporterColumnStatus(
        name: item.name,
        status: item.statusName,
      ),
      subtitle: MetaBlock.withString(context, <String>[
        '庫存：${item.currentAmount}',
        '最大值：${item.totalAmount ?? '未設定'}',
      ]),
    );
  }

  @override
  Widget getHeader(BuildContext context) {
    return const Text('匯入後，為了避免影響「菜單」的狀況，並不會把舊的成分移除。');
  }
}
