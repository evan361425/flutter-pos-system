import 'package:flutter/material.dart';
import 'package:possystem/components/page/orderable_list.dart';
import 'package:possystem/models/catalog_model.dart';
import 'package:possystem/models/menu_model.dart';
import 'package:provider/provider.dart';

class CatalogOrderableList extends OrderableList<CatalogModel> {
  CatalogOrderableList({Key key, @required List<CatalogModel> items})
      : super(key: key, items: items, title: '排序產品種類');

  @override
  _CatalogOrderListState createState() => _CatalogOrderListState();
}

class _CatalogOrderListState extends OrderableListState<CatalogModel, int> {
  @override
  Future<void> onSubmit() async {
    final menu = context.read<MenuModel>();

    for (var i = 1, n = widget.items.length; i <= n; i++) {
      await widget.items[i - 1].update(menu, index: i);
    }
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
