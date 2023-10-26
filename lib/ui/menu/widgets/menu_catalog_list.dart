import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/slidable_item_list.dart';
import 'package:possystem/components/style/more_button.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

class MenuCatalogList extends StatelessWidget {
  final List<Catalog> catalogs;

  final void Function(Catalog) onSelected;

  const MenuCatalogList(
    this.catalogs, {
    Key? key,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SlidableItemList<Catalog, _Action>(
      withFAB: true,
      delegate: SlidableItemDelegate(
        items: catalogs,
        deleteValue: _Action.delete,
        tileBuilder: _tileBuilder,
        confirmContextBuilder: _confirmContextBuilder,
        actionBuilder: _actionBuilder,
        handleDelete: (item) => item.remove(),
      ),
    );
  }

  Iterable<BottomSheetAction<_Action>> _actionBuilder(catalog) {
    return <BottomSheetAction<_Action>>[
      BottomSheetAction(
        title: Text(S.menuCatalogUpdate),
        leading: const Icon(KIcons.modal),
        routePathParameters: {'id': catalog.id},
        route: Routes.menuCatalogModal,
      ),
      BottomSheetAction(
        title: Text(S.menuCatalogReorder),
        leading: const Icon(KIcons.reorder),
        route: Routes.menuReorder,
      ),
    ];
  }

  Widget _tileBuilder(
    BuildContext context,
    Catalog catalog,
    int index,
    VoidCallback showActions,
  ) {
    return ListTile(
      key: Key('catalog.${catalog.id}'),
      leading: catalog.avator,
      title: Text(catalog.name),
      trailing: EntryMoreButton(onPressed: showActions),
      subtitle: MetaBlock.withString(
        context,
        catalog.itemList.map((product) => product.name),
        emptyText: S.menuCatalogListEmptyProduct,
      ),
      onLongPress: showActions,
      onTap: () => onSelected(catalog),
    );
  }

  Widget _confirmContextBuilder(BuildContext context, Catalog catalog) {
    final moreCtx = S.menuCatalogDialogDeletionContent(catalog.length);
    return Text(S.dialogDeletionContent(catalog.name, moreCtx));
  }
}

enum _Action {
  delete,
}
