import 'package:flutter/material.dart';
import 'package:possystem/components/item_list.dart';
import 'package:possystem/models/catalog_model.dart';
import 'package:possystem/ui/menu/menu_routes.dart';

class CatalogList extends ItemList<CatalogModel> {
  CatalogList(List<CatalogModel> catalogs) : super(catalogs);

  @override
  void onDelete(CatalogModel catalog) {
    print('Deletet');
  }

  @override
  Widget itemTile(BuildContext context, CatalogModel catalog) {
    return ListTile(
      leading: CircleAvatar(child: Text(catalog.name[0])),
      title: Text(catalog.name, style: Theme.of(context).textTheme.headline6),
      subtitle: Text('${catalog.length} products'),
      onTap: () {
        if (shouldProcess()) {
          Navigator.of(context).pushNamed(
            MenuRoutes.catalog,
            arguments: catalog,
          );
        }
      },
    );
  }
}
