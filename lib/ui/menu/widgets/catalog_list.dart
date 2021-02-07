import 'package:flutter/material.dart';
import 'package:possystem/components/item_list.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/catalog_model.dart';
import 'package:possystem/routes.dart';

class CatalogList extends ItemList<CatalogModel> {
  CatalogList(List<CatalogModel> catalogs) : super(catalogs);

  @override
  void onDelete(CatalogModel catalog) {
    print('Deletet');
  }

  @override
  Widget itemTile(BuildContext context, CatalogModel catalog) {
    return ListTile(
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          catalog.enable
              ? Icon(Icons.check_circle, color: colorPositive)
              : Icon(Icons.remove_circle, color: colorWarning),
        ],
      ),
      title: Text(catalog.name, style: Theme.of(context).textTheme.headline6),
      subtitle: Text('${catalog.length} products'),
      onTap: () {
        if (shouldProcess()) {
          Navigator.of(context).pushNamed(Routes.catalog, arguments: catalog);
        }
      },
    );
  }
}
