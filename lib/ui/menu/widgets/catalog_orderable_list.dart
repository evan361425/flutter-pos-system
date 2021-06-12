import 'package:flutter/material.dart';
import 'package:possystem/components/page/orderable_list.dart';
import 'package:possystem/models/menu/catalog_model.dart';
import 'package:possystem/models/repository/menu_model.dart';

class CatalogOrderableList extends OrderableList<CatalogModel> {
  CatalogOrderableList({Key? key, required List<CatalogModel> items})
      : super(key: key, items: items, title: '排序產品種類');

  @override
  _CatalogOrderListState createState() => _CatalogOrderListState();
}

class _CatalogOrderListState extends OrderableListState<CatalogModel, int> {
  @override
  Future<void> handleSubmit() {
    return MenuModel.instance.reorderChilds(widget.items);
  }

  @override
  Widget itemBuilder(BuildContext context, int index) {
    final item = widget.items[index];
    return OrderableListItem(
      key: ValueKey(item.id),
      index: index,
      title: item.name,
    );
  }

  @override
  int get itemCount => widget.items.length;
}
