import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/slidable_item_list.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

class CatalogList extends StatelessWidget {
  final List<Catalog> catalogs;

  const CatalogList(this.catalogs);

  @override
  Widget build(BuildContext context) {
    return SlidableItemList<Catalog>(
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
        title: Text(tt('menu.catalog.order')),
        leading: Icon(Icons.reorder_sharp),
        onTap: () => Navigator.of(context)
            .pushReplacementNamed(Routes.menuCatalogReorder),
      ),
    ];
  }

  void _handleTap(BuildContext context, Catalog catalog) {
    Navigator.of(context).pushNamed(
      Routes.menuCatalog,
      arguments: catalog,
    );
  }

  Widget _tileBuilder(BuildContext context, Catalog catalog) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(catalog.name.characters.first.toUpperCase()),
      ),
      title: Text(catalog.name, style: Theme.of(context).textTheme.headline6),
      subtitle: MetaBlock.withString(
        context,
        catalog.itemList.map((product) => product.name),
        emptyText: tt('menu.product.unset'),
      ),
    );
  }

  Widget _warningContextBuilder(BuildContext context, Catalog catalog) {
    if (catalog.isEmpty) {
      return Text(tt('delete_confirm', {'name': catalog.name}));
    }

    return Text(tt(
      'menu.catalog.delete_confirm',
      {'name': catalog.name, 'count': catalog.length},
    ));
  }
}
