import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/translator.dart';

import 'preview_page.dart';

class IngredientPreviewPage extends PreviewPage<Ingredient> {
  const IngredientPreviewPage({
    super.key,
    required super.model,
    required super.items,
    super.progress,
    super.physics,
  });

  @override
  Widget buildItem(BuildContext context, Ingredient item) {
    return ListTile(
      key: Key('transit_preview.stock.${item.id}'),
      title: ImporterColumnStatus(
        name: item.name,
        status: item.statusName,
      ),
      subtitle: MetaBlock.withString(context, <String>[
        S.transitImportPreviewIngredientMetaAmount(item.currentAmount),
        S.transitImportPreviewIngredientMetaMaxAmount(item.totalAmount == null ? 0 : 1, item.totalAmount ?? 0),
      ]),
    );
  }

  @override
  String get helpMessage => S.transitImportPreviewIngredientConfirm;
}
