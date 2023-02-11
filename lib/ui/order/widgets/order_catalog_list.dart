import 'package:flutter/material.dart';
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
      return const SingleRowWrap(children: [
        ChoiceChip(
          selected: false,
          label: Text('尚未設定產品種類'),
        ),
      ]);
    }

    return SingleRowWrap(children: <Widget>[
      for (final catalog in widget.catalogs)
        ChoiceChip(
          // TODO: should dynamic add this when it is select,
          // wait to support the API.
          // avatar: catalog.avator,
          key: Key('order.catalog.${catalog.id}'),
          onSelected: (isSelected) {
            if (isSelected) {
              setState(() => selectedId = catalog.id);
              widget.handleSelected(catalog);
            }
          },
          selected: catalog.id == selectedId,
          tooltip: catalog.name,
          label: Text(catalog.name),
        ),
    ]);
  }

  @override
  void initState() {
    super.initState();
    selectedId = widget.catalogs.isEmpty ? '' : widget.catalogs.first.id;
  }
}
