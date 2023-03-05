import 'package:flutter/material.dart';
import 'package:possystem/components/style/single_row_warp.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/translator.dart';

class OrderCatalogList extends StatefulWidget {
  final List<Catalog> catalogs;

  final void Function(int) onSelected;

  final ValueNotifier<int> indexNotifier;

  const OrderCatalogList({
    Key? key,
    required this.catalogs,
    required this.indexNotifier,
    required this.onSelected,
  }) : super(key: key);

  @override
  State<OrderCatalogList> createState() => _OrderCatalogListState();
}

class _OrderCatalogListState extends State<OrderCatalogList> {
  late String selectedId;

  @override
  Widget build(BuildContext context) {
    if (widget.catalogs.isEmpty) {
      return SingleRowWrap(children: [
        ChoiceChip(
          selected: false,
          label: Text(S.orderCartEmptyCatalog),
        ),
      ]);
    }

    var index = 0;
    return SingleRowWrap(children: <Widget>[
      for (final catalog in widget.catalogs) _buildChoiceChip(catalog, index++),
    ]);
  }

  ChoiceChip _buildChoiceChip(Catalog catalog, int index) {
    return ChoiceChip(
      // TODO: should dynamic add this when it is select,
      // wait to support the API.
      // avatar: catalog.avator,
      key: Key('order.catalog.${catalog.id}'),
      onSelected: (isSelected) {
        if (isSelected) {
          setState(() => selectedId = catalog.id);
          widget.onSelected(index);
        }
      },
      selected: catalog.id == selectedId,
      tooltip: catalog.name,
      label: Text(catalog.name),
    );
  }

  @override
  void initState() {
    super.initState();
    widget.indexNotifier.addListener(() {
      if (mounted) {
        setState(() {
          final index = widget.indexNotifier.value;
          selectedId = widget.catalogs[index].id;
        });
      }
    });
    selectedId = widget.catalogs.isEmpty ? '' : widget.catalogs.first.id;
  }
}
