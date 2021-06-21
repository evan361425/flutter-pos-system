import 'package:flutter/material.dart';
import 'package:possystem/components/slidable_item_list.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/repository/menu_model.dart';
import 'package:possystem/models/stock/quantity_model.dart';
import 'package:possystem/routes.dart';

class QuantityList extends StatelessWidget {
  final List<QuantityModel> quantities;

  const QuantityList({Key? key, required this.quantities}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (quantities.isEmpty) return EmptyBody('stock.quantity.empty_body');

    return SlidableItemList<QuantityModel>(
      items: quantities,
      handleDelete: _handleDelete,
      handleTap: _handleTap,
      tileBuilder: _tileBuilder,
      warningContextBuilder: _warningContextBuilder,
    );
  }

  Future<void> _handleDelete(BuildContext context, QuantityModel quantity) {
    return MenuModel.instance.removeQuantities(quantity.id);
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
      subtitle: Text('預設比例：${quantity.defaultProportion}'),
    );
  }

  Widget _warningContextBuilder(BuildContext context, QuantityModel quantity) {
    final count = MenuModel.instance.getQuantities(quantity.id).length;
    final countText = count == 0
        ? TextSpan()
        : TextSpan(children: [
            TextSpan(text: '將會一同刪除掉 '),
            TextSpan(text: count.toString()),
            TextSpan(text: ' 個成份的份量\n\n'),
          ]);

    return RichText(
      text: TextSpan(
        text: '確定要刪除 ',
        children: [
          TextSpan(
            text: quantity.name,
            style: TextStyle(color: kNegativeColor),
          ),
          TextSpan(text: ' 嗎？\n\n'),
          countText,
          TextSpan(text: '此動作將無法復原！'),
        ],
        style: Theme.of(context).textTheme.bodyText1,
      ),
    );
  }
}
