import 'package:flutter/material.dart';
import 'package:possystem/components/page/slidable_item_list.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/models/catalog_model.dart';
import 'package:possystem/models/menu_model.dart';
import 'package:possystem/routes.dart';

class CatalogList extends StatelessWidget {
  const CatalogList(this.catalogs);

  final List<CatalogModel> catalogs;

  @override
  Widget build(BuildContext context) {
    return SlidableItemList<CatalogModel>(
      items: catalogs,
      onDelete: onDelete,
      tileBuilder: tileBuilder,
      warningContext: warningContextBuild,
      onTap: onTap,
    );
  }

  void onDelete(context, catalog) {
    final menu = context.read<MenuModel>();
    menu.removeCatalog(catalog.id);
  }

  Widget warningContextBuild(BuildContext context, CatalogModel catalog) {
    return Column(
      children: [
        Text('刪除將會連同${catalog.length}個產品一起刪除'),
        Text('此動作將無法復原'),
      ],
    );
  }

  Widget tileBuilder(BuildContext context, CatalogModel catalog) {
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
    );
  }

  void onTap(BuildContext context, CatalogModel catalog) {
    Navigator.of(context).pushNamed(
      Routes.catalog,
      arguments: catalog,
    );
  }
}
