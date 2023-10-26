import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/slidable_item_list.dart';
import 'package:possystem/components/style/more_button.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

class StockQuantityList extends StatelessWidget {
  final List<Quantity> quantities;

  const StockQuantityList({Key? key, required this.quantities})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SlidableItemList<Quantity, int>(
      withFAB: true,
      delegate: SlidableItemDelegate(
        items: quantities,
        deleteValue: 0,
        tileBuilder: _tileBuilder,
        confirmContextBuilder: _confirmContextBuilder,
        handleDelete: _handleDelete,
        actionBuilder: (quantity) => [
          BottomSheetAction(
            key: const Key('btn.edit'),
            title: const Text('編輯份量'),
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
      subtitle: Text(S.quantityMetaProportion(quantity.defaultProportion)),
      trailing: EntryMoreButton(onPressed: showActions),
      onLongPress: showActions,
      onTap: () => context.pushNamed(
        Routes.quantityModal,
        pathParameters: {'id': quantity.id},
      ),
    );
  }

  Widget _confirmContextBuilder(BuildContext context, Quantity quantity) {
    final count = Menu.instance.getQuantities(quantity.id).length;
    final moreCtx = S.quantityDialogDeletionContent(count);

    return Text(S.dialogDeletionContent(quantity.name, moreCtx));
  }
}
