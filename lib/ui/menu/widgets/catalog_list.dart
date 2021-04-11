import 'package:flutter/material.dart';
import 'package:possystem/components/page/slidable_item_list.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/menu/catalog_model.dart';
import 'package:possystem/models/repository/menu_model.dart';
import 'package:possystem/routes.dart';
import 'package:provider/provider.dart';

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

  void onDelete(BuildContext context, CatalogModel catalog) {
    debugPrint('Delete ${catalog.id} - ${catalog.name}');
    final menu = context.read<MenuModel>();
    menu.removeCatalog(catalog.id);
  }

  Widget warningContextBuild(BuildContext context, CatalogModel catalog) {
    final productCount = catalog.isEmpty
        ? TextSpan()
        : TextSpan(children: [
            TextSpan(text: '將會一同刪除掉 '),
            TextSpan(text: catalog.length.toString()),
            TextSpan(text: ' 個產品\n\n'),
          ]);

    return RichText(
      text: TextSpan(
        text: '確定要刪除 ',
        children: [
          TextSpan(text: catalog.name, style: TextStyle(color: kNegativeColor)),
          TextSpan(text: ' 嗎？\n\n'),
          productCount,
          TextSpan(text: '此動作將無法復原！'),
        ],
        style: Theme.of(context).textTheme.bodyText1,
      ),
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
      Routes.menuCatalog,
      arguments: catalog,
    );
  }
}
