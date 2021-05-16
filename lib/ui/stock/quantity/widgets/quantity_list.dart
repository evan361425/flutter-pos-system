import 'package:flutter/material.dart';
import 'package:possystem/components/page/slidable_item_list.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/repository/menu_model.dart';
import 'package:possystem/models/stock/quantity_model.dart';
import 'package:possystem/routes.dart';

class QuantityList extends StatelessWidget {
  const QuantityList({Key key, this.quantities}) : super(key: key);

  final List<QuantityModel> quantities;

  @override
  Widget build(BuildContext context) {
    return SlidableItemList<QuantityModel>(
      items: quantities,
      onDelete: _onDelete,
      tileBuilder: _tileBuilder,
      warningContext: _warningContext,
      onTap: _onTap,
    );
  }

  Future<void> _onDelete(BuildContext context, QuantityModel quantity) async {
    await quantity.remove();
    return MenuModel.instance.removeQuantities(quantity.id);
  }

  Widget _tileBuilder(BuildContext context, QuantityModel quantity) {
    return ListTile(
      title: Text(quantity.name, style: Theme.of(context).textTheme.headline6),
      subtitle: Text('預設比例：${quantity.defaultProportion}'),
    );
  }

  Widget _warningContext(BuildContext context, QuantityModel quantity) {
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

  void _onTap(BuildContext context, QuantityModel quantity) {
    Navigator.of(context).pushNamed(
      Routes.stockQuantityModal,
      arguments: quantity,
    );
  }
}
