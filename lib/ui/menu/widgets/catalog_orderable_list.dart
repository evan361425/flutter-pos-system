import 'package:flutter/material.dart';
import 'package:possystem/components/orderable_list.dart';
import 'package:possystem/models/catalog_model.dart';

class CatalogOrderableList extends OrderableList<CatalogModel> {
  CatalogOrderableList({Key key, @required List<CatalogModel> items})
      : super(key: key, items: items, title: '排序產品種類');

  @override
  _CatalogOrderListState createState() => _CatalogOrderListState();
}

class _CatalogOrderListState extends OrderableListState<CatalogModel, int> {
  @override
  int indexOfKey(int key) {
    return widget.items.indexWhere((item) => item.index == key);
  }

  @override
  Future<void> onSubmit() {
    // TODO: implement onSubmit
    throw UnimplementedError();
  }

  @override
  Widget itemBuilder(BuildContext context, int index) {
    final item = widget.items[index];
    return OrderableListItem(
      key: ValueKey(item.index),
      index: index,
      title: item.name,
    );
  }

  @override
  int get itemCount => widget.items.length;
}
