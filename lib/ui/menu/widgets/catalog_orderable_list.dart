import 'package:flutter/material.dart';
import 'package:possystem/components/scaffold/reorderable_scaffold.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/translator.dart';

class CatalogOrderableList extends StatelessWidget {
  const CatalogOrderableList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ReorderableScaffold(
      items: Menu.instance.itemList,
      title: S.menuCatalogReorder,
      handleSubmit: (List<Catalog> items) => Menu.instance.reorderItems(items),
    );
  }
}
