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
    return SlidableItemList<Quantity, _Action>(
      items: quantities,
      deleteValue: _Action.delete,
      tileBuilder: _tileBuilder,
      warningContextBuilder: _warningContextBuilder,
      handleDelete: _handleDelete,
      handleTap: _handleTap,
    );
  }

  Future<void> _handleDelete(_, quantity) async {
    await quantity.remove();
    return Menu.instance.removeQuantities(quantity.id);
  }

  void _handleTap(BuildContext context, Quantity quantity) {
    Navigator.of(context).pushNamed(
      Routes.stockQuantityModal,
      arguments: quantity,
    );
  }

  Widget _tileBuilder(BuildContext context, int index, Quantity quantity) {
    return ListTile(
      title: Text(quantity.name, style: Theme.of(context).textTheme.headline6),
      subtitle: Text(tt(
        'stock.quantity.proportion',
        {'proportion': quantity.defaultProportion},
      )),
    );
  }

  Widget _warningContextBuilder(BuildContext context, Quantity quantity) {
    final count = Menu.instance.getQuantities(quantity.id).length;

    if (count == 0) {
      return Text(tt('delete_confirm', {'name': quantity.name}));
    }

    return Text(tt(
      'stock.quantity.delete_confirm',
      {'name': quantity.name, 'count': count},
    ));
  }
}

enum _Action {
  delete,
}
