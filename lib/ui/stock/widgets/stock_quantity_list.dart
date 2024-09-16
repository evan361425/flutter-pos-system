import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/slidable_item_list.dart';
import 'package:possystem/components/style/buttons.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

class StockQuantityList extends StatelessWidget {
  final List<Quantity> quantities;

  final Widget leading;

  const StockQuantityList({
    super.key,
    required this.quantities,
    required this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return SlidableItemList<Quantity, int>(
      leading: leading,
      delegate: SlidableItemDelegate(
        items: quantities,
        deleteValue: 0,
        tileBuilder: (item, _, actorBuilder) => _Tile(item, actorBuilder),
        warningContentBuilder: _warningContentBuilder,
        handleDelete: _handleDelete,
        actionBuilder: (quantity) => [
          BottomSheetAction(
            key: const Key('btn.edit'),
            title: Text(S.menuQuantityTitleUpdate),
            leading: const Icon(KIcons.edit),
            route: Routes.quantityUpdate,
            routePathParameters: {'id': quantity.id},
          ),
        ],
      ),
    );
  }

  Future<void> _handleDelete(Quantity quantity) async {
    await quantity.remove();
    return Menu.instance.removeQuantities(quantity.id);
  }

  Widget _warningContentBuilder(BuildContext context, Quantity quantity) {
    final count = Menu.instance.getQuantities(quantity.id).length;
    final more = S.stockQuantityDialogDeletionContent(count);

    return Text(S.dialogDeletionContent(quantity.name, '$more\n\n'));
  }
}

class _Tile extends StatelessWidget {
  final Quantity item;
  final ActorBuilder actorBuilder;

  const _Tile(this.item, this.actorBuilder);

  @override
  Widget build(BuildContext context) {
    final actor = actorBuilder(context);
    return ListTile(
      key: Key('quantities.${item.id}'),
      title: Text(item.name),
      subtitle: Text(S.stockQuantityMetaProportion(item.defaultProportion)),
      trailing: EntryMoreButton(onPressed: actor),
      onLongPress: actor,
      onTap: () => context.pushNamed(
        Routes.quantityUpdate,
        pathParameters: {'id': item.id},
      ),
    );
  }
}
