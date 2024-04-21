import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/translator.dart';

import 'preview_page.dart';

class QuantityPreviewPage extends PreviewPage<Quantity> {
  const QuantityPreviewPage({
    super.key,
    required super.items,
  });

  @override
  Widget getItem(BuildContext context, Quantity item) {
    return ListTile(
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
  Widget getHeader(BuildContext context) {
    return Text(S.transitImportPreviewQuantityHeader);
  }
}
