import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/slidable_item_list.dart';
import 'package:possystem/components/tip/tip_tutorial.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

class CatalogList extends StatelessWidget {
  final List<Catalog> catalogs;

  const CatalogList(this.catalogs, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SlidableItemList<Catalog, _Action>(
      items: catalogs,
      deleteValue: _Action.delete,
      tileBuilder: _tileBuilder,
      warningContextBuilder: _warningContextBuilder,
      actionBuilder: _actionBuilder,
      handleTap: _handleTap,
      handleDelete: (item) => item.remove(),
    );
  }

  Iterable<BottomSheetAction<_Action>> _actionBuilder(catalog) {
    return <BottomSheetAction<_Action>>[
      BottomSheetAction(
        title: Text(tt('menu.catalog.edit')),
        leading: const Icon(Icons.text_fields_sharp),
        navigateArgument: catalog,
        navigateRoute: Routes.menuCatalogModal,
      ),
      BottomSheetAction(
        title: Text(tt('menu.catalog.order')),
        leading: const Icon(Icons.reorder_sharp),
        navigateArgument: catalog,
        navigateRoute: Routes.menuCatalogReorder,
      ),
    ];
  }

  void _handleTap(BuildContext context, Catalog catalog) {
    Navigator.of(context).pushNamed(
      Routes.menuCatalog,
      arguments: catalog,
    );
  }

  Widget _tileBuilder(BuildContext context, int index, Catalog catalog) {
    final child = ListTile(
      key: Key('catalog.${catalog.id}'),
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
    if (index == 0) {
      return TipTutorial(
        message: '「長按」- 重新排序或編輯 產品種類\n「滑動」- 刪除 產品種類',
        label: 'menu.cagtalog.item',
        child: child,
      );
    }

    return child;
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

enum _Action {
  delete,
}
