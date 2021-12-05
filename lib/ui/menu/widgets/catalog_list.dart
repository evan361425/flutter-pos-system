import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/slidable_item_list.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:simple_tip/simple_tip.dart';

class CatalogList extends StatelessWidget {
  final List<Catalog> catalogs;

  final GlobalKey<TipGrouperState>? tipGrouper;

  const CatalogList(
    this.catalogs, {
    Key? key,
    this.tipGrouper,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SlidableItemList<Catalog, int>(
        delegate: SlidableItemDelegate(
      items: catalogs,
      deleteValue: 0,
      tileBuilder: _tileBuilder,
      warningContextBuilder: _warningContextBuilder,
      actionBuilder: _actionBuilder,
      handleTap: _handleTap,
      handleDelete: (item) => item.remove(),
    ));
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

  Widget _tileBuilder(BuildContext context, int index, Catalog catalog, _) {
    final child = ListTile(
      key: Key('catalog.${catalog.id}'),
      leading: catalog.avator,
      title: Text(catalog.name),
      subtitle: MetaBlock.withString(
        context,
        catalog.itemList.map((product) => product.name),
        emptyText: S.menuCatalogListEmptyProduct,
      ),
    );
    if (index == 0) {
      return OrderedTip(
        id: 'cagtalog_item',
        grouper: tipGrouper,
        message: '「長按」- 重新排序或編輯 產品種類\n「滑動」- 刪除 產品種類',
        order: 10,
        version: 1,
        child: child,
      );
    }

    return child;
  }

  Widget _warningContextBuilder(BuildContext context, Catalog catalog) {
    final moreCtx = S.menuCatalogDialogDeletionContent(catalog.length);
    return Text(S.dialogDeletionContent(catalog.name, moreCtx));
  }
}
