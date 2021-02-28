import 'package:flutter/material.dart';
import 'package:possystem/components/item_list.dart';
import 'package:possystem/components/meta_block.dart';
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
      leading: CircleAvatar(
        child: Text(catalog.name.characters.first.toUpperCase()),
      ),
      title: Text(catalog.name, style: Theme.of(context).textTheme.headline6),
      subtitle: MetaBlock.withString(
        catalog.products.map((product) => product.name),
        context,
      ),
      onTap: () {
        if (shouldProcess()) {
          Navigator.of(context).pushNamed(
            Routes.catalog,
            arguments: catalog,
          );
        }
      },
    );
  }
}
