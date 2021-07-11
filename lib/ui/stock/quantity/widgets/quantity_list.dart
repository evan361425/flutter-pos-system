import 'package:flutter/material.dart';
import 'package:possystem/components/slidable_item_list.dart';
import 'package:possystem/models/repository/menu_model.dart';
import 'package:possystem/models/stock/quantity_model.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

class QuantityList extends StatelessWidget {
  final List<QuantityModel> quantities;

  const QuantityList({Key? key, required this.quantities}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SlidableItemList<QuantityModel>(
      items: quantities,
      handleDelete: (_, quantity) =>
          MenuModel.instance.removeQuantities(quantity.id),
      handleTap: _handleTap,
      tileBuilder: _tileBuilder,
      warningContextBuilder: _warningContextBuilder,
    );
  }

  void _handleTap(BuildContext context, QuantityModel quantity) {
    Navigator.of(context).pushNamed(
      Routes.stockQuantityModal,
      arguments: quantity,
    );
  }

  Widget _tileBuilder(BuildContext context, QuantityModel quantity) {
    return ListTile(
      title: Text(quantity.name, style: Theme.of(context).textTheme.headline6),
      subtitle: Text(tt(
        'stock.quantity.proportion',
        {'proportion': quantity.defaultProportion},
      )),
    );
  }

  Widget _warningContextBuilder(BuildContext context, QuantityModel quantity) {
    final count = MenuModel.instance.getQuantities(quantity.id).length;

    if (count == 0) {
      return Text(tt('delete_confirm', {'name': quantity.name}));
    }

    return Text(tt(
      'stock.quantity.delete_confirm',
      {'name': quantity.name, 'count': count},
    ));
  }
}
