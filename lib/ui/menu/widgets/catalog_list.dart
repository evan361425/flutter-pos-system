import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/slidable_item_list.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

class CatalogList extends StatelessWidget {
  final List<Catalog> catalogs;

  const CatalogList(
    this.catalogs, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SlidableItemList<Catalog, int>(
      delegate: SlidableItemDelegate(
        groupTag: 'menu.catalog',
        items: catalogs,
        deleteValue: 0,
        tileBuilder: _tileBuilder,
        warningContextBuilder: _warningContextBuilder,
        actionBuilder: _actionBuilder,
        handleTap: _handleTap,
        handleDelete: (item) => item.remove(),
      ),
    );
  }

  Iterable<BottomSheetAction<int>> _actionBuilder(catalog) {
    return <BottomSheetAction<int>>[
      BottomSheetAction(
        title: Text(S.menuCatalogUpdate),
        leading: const Icon(Icons.text_fields_sharp),
        navigateArgument: catalog,
        navigateRoute: Routes.menuCatalogModal,
      ),
      BottomSheetAction(
        title: Text(S.menuCatalogReorder),
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

  Widget _tileBuilder(
    BuildContext context,
    int index,
    Catalog catalog,
    VoidCallback showActions,
  ) {
    final child = ListTile(
      key: Key('catalog.${catalog.id}'),
      leading: catalog.avator,
      title: Text(catalog.name),
      trailing: IconButton(
        onPressed: showActions,
        icon: const Icon(Icons.more_vert_sharp),
      ),
      subtitle: MetaBlock.withString(
        context,
        catalog.itemList.map((product) => product.name),
        emptyText: S.menuCatalogListEmptyProduct,
      ),
    );

    return child;
  }

  Widget _warningContextBuilder(BuildContext context, Catalog catalog) {
    final moreCtx = S.menuCatalogDialogDeletionContent(catalog.length);
    return Text(S.dialogDeletionContent(catalog.name, moreCtx));
  }
}
