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

  const StockQuantityList({super.key, required this.quantities});

  @override
  Widget build(BuildContext context) {
    return SlidableItemList<Quantity, int>(
      delegate: SlidableItemDelegate(
        items: quantities,
        deleteValue: 0,
        tileBuilder: _tileBuilder,
        warningContentBuilder: _warningContentBuilder,
        handleDelete: _handleDelete,
        actionBuilder: (quantity) => [
          BottomSheetAction(
            key: const Key('btn.edit'),
            title: Text(S.menuQuantityTitleUpdate),
            leading: const Icon(KIcons.edit),
            route: Routes.quantityModal,
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

  Widget _tileBuilder(
    BuildContext context,
    Quantity quantity,
    int index,
    VoidCallback showActions,
  ) {
    return ListTile(
      key: Key('quantities.${quantity.id}'),
      title: Text(quantity.name),
      subtitle: Text(S.stockQuantityMetaProportion(quantity.defaultProportion)),
      trailing: EntryMoreButton(onPressed: showActions),
      onLongPress: showActions,
      onTap: () => context.pushNamed(
        Routes.quantityModal,
        pathParameters: {'id': quantity.id},
      ),
    );
  }

  Widget _warningContentBuilder(BuildContext context, Quantity quantity) {
    final count = Menu.instance.getQuantities(quantity.id).length;
    final more = S.stockQuantityDialogDeletionContent(count);

    return Text(S.dialogDeletionContent(quantity.name, '$more\n\n'));
  }
}
