import 'package:flutter/material.dart';
import 'package:possystem/components/style/single_row_warp.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/order/order_page.dart';

class OrderCatalogListView extends StatefulWidget {
  final List<Catalog> catalogs;

  final void Function(int) onSelected;

  final ValueNotifier<int> indexNotifier;

  final ValueNotifier<ProductListView> viewNotifier;

  const OrderCatalogListView({
    super.key,
    required this.catalogs,
    required this.indexNotifier,
    required this.onSelected,
    required this.viewNotifier,
  });

  @override
  State<OrderCatalogListView> createState() => _OrderCatalogListViewState();
}

class _OrderCatalogListViewState extends State<OrderCatalogListView> {
  final FocusNode _f = FocusNode(debugLabel: 'OrderCatalogListView');
  final MenuController controller = MenuController();
  late String selectedId;

  @override
  Widget build(BuildContext context) {
    if (widget.catalogs.isEmpty) {
      return SingleRowWrap(children: [
        ChoiceChip(
          selected: false,
          label: Text(S.orderCatalogListEmpty),
        ),
      ]);
    }

    var index = 0;
    return Material(
      elevation: 1.0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
        child: Row(
          children: [
            const SizedBox(width: 4),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Wrap(spacing: 6, children: [
                  for (final catalog in widget.catalogs) _buildChoiceChip(catalog, index++),
                  const SizedBox(),
                ]),
              ),
            ),
            _ProductListView(
              controller: controller,
              focusNode: _f,
              viewNotifier: widget.viewNotifier,
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _f.dispose();
    super.dispose();
  }

  ChoiceChip _buildChoiceChip(Catalog catalog, int index) {
    return ChoiceChip(
      // TODO: should dynamic add this when it is select,
      // wait to support the API.
      avatar: selectedId == catalog.id ? null : catalog.avator,
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

class _ProductListView extends StatelessWidget {
  const _ProductListView({
    required this.controller,
    required this.focusNode,
    required this.viewNotifier,
  });

  final MenuController controller;
  final FocusNode focusNode;
  final ValueNotifier<ProductListView> viewNotifier;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1),
          borderRadius: BorderRadius.horizontal(right: Radius.circular(8)),
        ),
      ),
      // TODO: use AnimatedIcon
      child: MenuAnchor(
        controller: controller,
        childFocusNode: focusNode,
        menuChildren: ProductListView.values.map((e) {
          return MenuItemButton(
            leadingIcon: e.icon,
            onPressed: () => viewNotifier.value = e,
            child: Text(S.orderProductListViewHelper(e.name)),
          );
        }).toList(),
        child: ListenableBuilder(
          listenable: viewNotifier,
          builder: (context, child) {
            return IconButton(
              focusNode: focusNode,
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              onPressed: controller.toggle,
              icon: viewNotifier.value.icon,
            );
          },
        ),
      ),
    );
  }
}
