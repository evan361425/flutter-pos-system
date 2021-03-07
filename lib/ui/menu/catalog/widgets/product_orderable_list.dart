import 'package:flutter/material.dart';
import 'package:possystem/components/orderable_list.dart';
import 'package:possystem/models/product_model.dart';

class ProductOrderableList extends OrderableList<ProductModel> {
  ProductOrderableList({Key key, @required List<ProductModel> items})
      : super(key: key, items: items, title: '排序產品');

  @override
  _ProductOrderListState createState() => _ProductOrderListState();
}

class _ProductOrderListState extends OrderableListState<ProductModel, int> {
  @override
  Widget listWithScrollableView() {
    return ListView.builder(
      itemCount: widget.items.length,
      itemBuilder: (BuildContext context, int index) {
        final item = widget.items[index];
        return OrderableListItem<int>(
          title: item.name,
          keyValue: item.index,
        );
      },
    );
  }

  @override
  int indexOfKey(int key) {
    return widget.items.indexWhere((item) => item.index == key);
  }

  @override
  Future<void> onSubmit() {
    // TODO: implement onSubmit
    throw UnimplementedError();
  }
}
