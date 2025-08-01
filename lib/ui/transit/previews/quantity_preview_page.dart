import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/translator.dart';

import 'preview_page.dart';

class QuantityPreviewPage extends PreviewPage<Quantity> {
  const QuantityPreviewPage({
    super.key,
    required super.model,
    required super.items,
    super.progress,
    super.physics,
  });

  @override
  Widget buildItem(BuildContext context, Quantity item) {
    return ListTile(
      key: Key('transit_preview.quantities.${item.id}'),
      title: ImporterColumnStatus(
        name: item.name,
        status: item.statusName,
      ),
      subtitle: MetaBlock.withString(context, <String>[
        S.stockQuantityMetaProportion(item.defaultProportion),
      ]),
    );
  }

  @override
  String get helpMessage => S.transitImportPreviewQuantityConfirm;
}
