import 'package:flutter/material.dart';
import 'package:possystem/components/style/radio_text.dart';
import 'package:possystem/components/style/single_row_warp.dart';
import 'package:possystem/models/menu/catalog.dart';

class OrderCatalogList extends StatefulWidget {
  final List<Catalog> catalogs;

  final void Function(Catalog) handleSelected;

  const OrderCatalogList({
    Key? key,
    required this.catalogs,
    required this.handleSelected,
  }) : super(key: key);

  @override
  State<OrderCatalogList> createState() => _OrderCatalogListState();
}

class _OrderCatalogListState extends State<OrderCatalogList> {
  late String selectedId;

  @override
  Widget build(BuildContext context) {
    if (widget.catalogs.isEmpty) {
      return SingleRowWrap(children: [RadioText.empty()]);
    }

    return SingleRowWrap(children: <Widget>[
      for (final catalog in widget.catalogs)
        RadioText(
          key: Key('order.catalog.${catalog.id}'),
          onChanged: (_) {
            setState(() => selectedId = catalog.id);
            widget.handleSelected(catalog);
          },
          isSelected: catalog.id == selectedId,
          text: catalog.name,
        ),
    ]);
  }

  @override
  void initState() {
    super.initState();
    selectedId = widget.catalogs.isEmpty ? '' : widget.catalogs.first.id;
  }
}
