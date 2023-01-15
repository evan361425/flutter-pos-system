import 'package:flutter/material.dart';
import 'package:possystem/components/slidable_item_list.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

class QuantityList extends StatelessWidget {
  final List<Quantity> quantities;

  const QuantityList({Key? key, required this.quantities}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SlidableItemList<Quantity, int>(
      delegate: SlidableItemDelegate(
        groupTag: 'quantities.quantity',
        items: quantities,
        deleteValue: 0,
        tileBuilder: _tileBuilder,
        warningContextBuilder: _warningContextBuilder,
        handleDelete: _handleDelete,
        handleTap: _handleTap,
      ),
    );
  }

  Future<void> _handleDelete(Quantity quantity) async {
    await quantity.remove();
    return Menu.instance.removeQuantities(quantity.id);
  }

  void _handleTap(BuildContext context, Quantity quantity) {
    Navigator.of(context).pushNamed(
      Routes.quantityModal,
      arguments: quantity,
    );
  }

  Widget _tileBuilder(
    BuildContext context,
    int index,
    Quantity quantity,
    VoidCallback showActions,
  ) {
    return ListTile(
      key: Key('quantities.${quantity.id}'),
      title: Text(quantity.name),
      subtitle: Text(S.quantityMetaProportion(quantity.defaultProportion)),
      trailing: IconButton(
        onPressed: showActions,
        icon: const Icon(Icons.more_vert_sharp),
      ),
    );
  }

  Widget _warningContextBuilder(BuildContext context, Quantity quantity) {
    final count = Menu.instance.getQuantities(quantity.id).length;
    final moreCtx = S.quantityDialogDeletionContent(count);

    return Text(S.dialogDeletionContent(quantity.name, moreCtx));
  }
}
