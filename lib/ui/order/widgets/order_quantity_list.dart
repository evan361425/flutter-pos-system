import 'package:flutter/cupertino.dart';
import 'package:possystem/components/radio_text.dart';
import 'package:possystem/components/style/single_row_warp.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/order/order_ingredient.dart';
import 'package:possystem/models/repository/cart.dart';

import '../../../translator.dart';

class OrderQuantityList extends StatefulWidget {
  final ProductIngredient ingredient;

  final String? selected;

  const OrderQuantityList({
    Key? key,
    required this.ingredient,
    required this.selected,
  }) : super(key: key);

  @override
  OrderQuantityListState createState() => OrderQuantityListState();
}

class OrderQuantityListState extends State<OrderQuantityList> {
  static const _QUANTITY_RADIO_KEY = 'order.quantities';

  late ProductIngredient ingredient;

  String? selected;

  @override
  Widget build(BuildContext context) {
    return SingleRowWrap(children: <Widget>[
      RadioText(
        onSelected: () => Cart.instance.removeSelectedIngredient(ingredient.id),
        groupId: _QUANTITY_RADIO_KEY,
        value: Cart.DEFAULT_QUANTITY_ID,
        isSelected: Cart.DEFAULT_QUANTITY_ID == selected,
        child: Text(tt(
          'order.list.default_quantity',
          {'amount': ingredient.amount},
        )),
      ),
      for (final quantity in ingredient.items)
        RadioText(
          onSelected: () {
            Cart.instance.updateSelectedIngredient(OrderIngredient(
              ingredient: ingredient,
              quantity: quantity,
            ));
          },
          groupId: _QUANTITY_RADIO_KEY,
          value: quantity.id,
          isSelected: quantity.id == selected,
          child: Text('${quantity.name}（${quantity.amount}）'),
        ),
    ]);
  }

  @override
  void initState() {
    ingredient = widget.ingredient;
    selected = widget.selected;
    super.initState();
  }

  void update({
    required ProductIngredient ingredient,
    String? selected,
  }) {
    setState(() {
      this.ingredient = ingredient;
      this.selected = selected;
    });
  }
}
