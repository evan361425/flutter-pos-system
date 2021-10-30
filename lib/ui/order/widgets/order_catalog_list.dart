import 'package:flutter/material.dart';
import 'package:possystem/components/radio_text.dart';
import 'package:possystem/components/style/single_row_warp.dart';
import 'package:possystem/models/menu/catalog.dart';

class OrderCatalogList extends StatelessWidget {
  final List<Catalog> catalogs;

  final void Function(Catalog) handleSelected;

  static const _radioKey = 'order.catalogs';

  const OrderCatalogList({
    Key? key,
    required this.catalogs,
    required this.handleSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (catalogs.isEmpty) {
      return SingleRowWrap(children: [RadioText.empty()]);
    }

    return SingleRowWrap(children: <Widget>[
      for (final catalog in catalogs)
        RadioText(
          key: Key('order.catalog.${catalog.id}'),
          onSelected: (_) => handleSelected(catalog),
          groupId: _radioKey,
          value: catalog.id,
          text: catalog.name,
        ),
    ]);
  }
}
