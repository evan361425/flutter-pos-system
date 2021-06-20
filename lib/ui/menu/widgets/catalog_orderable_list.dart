import 'package:flutter/material.dart';
import 'package:possystem/components/scaffold/reorderable_scaffold.dart';
import 'package:possystem/models/menu/catalog_model.dart';
import 'package:possystem/models/repository/menu_model.dart';

class CatalogOrderableList extends StatelessWidget {
  const CatalogOrderableList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('build reorder');

    return ReorderableScaffold(
      items: MenuModel.instance.itemList,
      title: '排序產品種類',
      handleSubmit: (List<CatalogModel> items) =>
          MenuModel.instance.reorderItems(items),
    );
  }
}
