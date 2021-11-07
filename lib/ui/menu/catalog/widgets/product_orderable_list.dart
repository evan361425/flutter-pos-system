import 'package:flutter/material.dart';
import 'package:possystem/components/scaffold/reorderable_scaffold.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/translator.dart';

class ProductOrderableList extends StatelessWidget {
  final Catalog catalog;

  const ProductOrderableList(this.catalog, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ReorderableScaffold(
      items: catalog.itemList,
      title: S.menuProductReorder,
      handleSubmit: (List<Product> items) => catalog.reorderItems(items),
    );
  }
}
