import 'package:flutter/material.dart';
import 'package:possystem/components/scaffold/reorderable_scaffold.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/translator.dart';

class ProductOrderableList extends StatelessWidget {
  const ProductOrderableList({Key? key, required this.catalog})
      : super(key: key);

  final Catalog catalog;

  @override
  Widget build(BuildContext context) {
    return ReorderableScaffold(
      items: catalog.itemList,
      title: tt('menu.product.order'),
      handleSubmit: (List<Product> items) => catalog.reorderItems(items),
    );
  }
}
