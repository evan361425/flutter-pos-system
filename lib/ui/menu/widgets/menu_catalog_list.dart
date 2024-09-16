import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/slidable_item_list.dart';
import 'package:possystem/components/style/buttons.dart';
import 'package:possystem/components/style/route_buttons.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

class MenuCatalogList extends StatelessWidget {
  final List<Catalog> catalogs;

  final Widget leading;
  final void Function(Catalog) onSelected;

  const MenuCatalogList(
    this.catalogs, {
    super.key,
    required this.onSelected,
    required this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return SlidableItemList<Catalog, _Action>(
      leading: leading,
      action: RouteIconButton(
        label: S.menuCatalogTitleReorder,
        icon: const Icon(KIcons.reorder),
        route: Routes.menuCatalogReorder,
        hideLabel: true,
      ),
      delegate: SlidableItemDelegate(
        items: catalogs,
        deleteValue: _Action.delete,
        tileBuilder: (catalog, _, actorBuilder) => _Tile(catalog, actorBuilder, onSelected),
        warningContentBuilder: _warningContentBuilder,
        actionBuilder: (Catalog catalog) => <BottomSheetAction<_Action>>[
          BottomSheetAction(
            title: Text(S.menuCatalogTitleUpdate),
            leading: const Icon(KIcons.modal),
            routePathParameters: {'id': catalog.id},
            route: Routes.menuCatalogUpdate,
          ),
          BottomSheetAction(
            title: Text(S.menuProductTitleReorder),
            leading: const Icon(KIcons.reorder),
            route: Routes.menuProductReorder,
            routePathParameters: {'id': catalog.id},
          ),
        ],
        handleDelete: (item) => item.remove(),
      ),
    );
  }

  Widget _warningContentBuilder(BuildContext context, Catalog catalog) {
    final more = S.menuCatalogDialogDeletionContent(catalog.length);
    return Text(S.dialogDeletionContent(catalog.name, '$more\n\n'));
  }
}

class _Tile extends StatelessWidget {
  final Catalog catalog;
  final ActorBuilder actorBuilder;
  final void Function(Catalog) onSelected;

  const _Tile(this.catalog, this.actorBuilder, this.onSelected);

  @override
  Widget build(BuildContext context) {
    final actor = actorBuilder(context);

    return ListTile(
      key: Key('catalog.${catalog.id}'),
      leading: catalog.avator,
      title: Text(catalog.name),
      trailing: EntryMoreButton(onPressed: actor),
      subtitle: MetaBlock.withString(
        context,
        catalog.itemList.map((product) => product.name),
        emptyText: S.menuCatalogEmptyProducts,
      ),
      onLongPress: actor,
      onTap: () => onSelected(catalog),
    );
  }
}

enum _Action {
  delete,
}
