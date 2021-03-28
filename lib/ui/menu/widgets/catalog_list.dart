import 'package:flutter/material.dart';
import 'package:possystem/components/page/item_list.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/models/catalog_model.dart';
import 'package:possystem/models/menu_model.dart';
import 'package:possystem/routes.dart';
import 'package:provider/provider.dart';

class CatalogList extends ItemList<CatalogModel> {
  CatalogList(List<CatalogModel> catalogs) : super(catalogs);

  @override
  Future<void> onDelete(context, catalog) async {
    final menu = context.read<MenuModel>();
    menu.removeCatalog(catalog.id);
  }

  @override
  Widget itemTile(BuildContext context, CatalogModel catalog) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(catalog.name.characters.first.toUpperCase()),
      ),
      title: Text(catalog.name, style: Theme.of(context).textTheme.headline6),
      subtitle: MetaBlock.withString(
        context,
        catalog.productList.map((product) => product.name),
        '尚未設定產品',
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
