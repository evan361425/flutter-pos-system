import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/slidable_item_list.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/menu/catalog_model.dart';
import 'package:possystem/routes.dart';

class CatalogList extends StatelessWidget {
  final List<CatalogModel> catalogs;

  const CatalogList(this.catalogs);

  @override
  Widget build(BuildContext context) {
    return SlidableItemList<CatalogModel>(
      items: catalogs,
      tileBuilder: _tileBuilder,
      warningContextBuilder: _warningContextBuilder,
      handleTap: _handleTap,
      actionBuilder: _actionBuilder,
    );
  }

  Iterable<Widget> _actionBuilder(BuildContext context, _) {
    return [
      ListTile(
        title: Text('排序產品種類'),
        leading: Icon(Icons.reorder_sharp),
        onTap: () =>
            Navigator.of(context).pushReplacementNamed(Routes.menuReorder),
      ),
    ];
  }

  void _handleTap(BuildContext context, CatalogModel catalog) {
    Navigator.of(context).pushNamed(
      Routes.menuCatalog,
      arguments: catalog,
    );
  }

  Widget _tileBuilder(BuildContext context, CatalogModel catalog) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(catalog.name.characters.first.toUpperCase()),
      ),
      title: Text(catalog.name, style: Theme.of(context).textTheme.headline6),
      subtitle: MetaBlock.withString(
        context,
        catalog.itemList.map((product) => product.name),
        emptyText: '尚未設定產品',
      ),
    );
  }

  Widget _warningContextBuilder(BuildContext context, CatalogModel catalog) {
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
}
