import 'package:flutter/material.dart';
import 'package:possystem/components/scaffold/reorderable_scaffold.dart';
import 'package:possystem/models/menu/catalog_model.dart';
import 'package:possystem/models/repository/menu_model.dart';
import 'package:possystem/translator.dart';

class CatalogOrderableList extends StatelessWidget {
  const CatalogOrderableList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ReorderableScaffold(
      items: MenuModel.instance.itemList,
      title: tt('menu.catalog.order'),
      handleSubmit: (List<CatalogModel> items) =>
          MenuModel.instance.reorderItems(items),
    );
  }
}
