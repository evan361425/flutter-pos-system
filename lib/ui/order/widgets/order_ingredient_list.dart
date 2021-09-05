import 'package:flutter/material.dart';
import 'package:possystem/components/radio_text.dart';
import 'package:possystem/components/style/single_row_warp.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/order/order_product.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/order/widgets/order_quantity_list.dart';

class OrderIngredientList extends StatefulWidget {
  const OrderIngredientList({Key? key}) : super(key: key);

  @override
  _OrderIngredientListState createState() => _OrderIngredientListState();
}

class _OrderIngredientListState extends State<OrderIngredientList> {
  static const _INGREDIENT_RADIO_KEY = 'order.ingredients';

  final quantityList = GlobalKey<OrderQuantityListState>();

  @override
  Widget build(BuildContext context) {
    if (Cart.instance.isEmpty) {
      return _emptyRows(context, tt('order.list.cart_empty'));
    }
    if (!Cart.instance.isSameProducts) {
      return _emptyRows(context, tt('order.list.not_same_product'));
    }

    final product = Cart.instance.selected.first.product;
    final ingredients = product.ingredientsWithQuantity;
    if (ingredients.isEmpty) {
      return _emptyRows(context, tt('order.list.no_quantity'));
    }

    final selected = ingredients.first;
    final quantityId = Cart.instance.getSelectedQuantityId(selected);
    quantityList.currentState?.update(
      ingredient: selected,
      selected: quantityId,
    );

    return _rowWrapper([
      SingleRowWrap(children: <Widget>[
        for (final ingredient in ingredients)
          RadioText(
            onSelected: (_) {
              quantityList.currentState?.update(
                ingredient: ingredient,
                selected: Cart.instance.getSelectedQuantityId(ingredient),
              );
            },
            groupId: _INGREDIENT_RADIO_KEY,
            isSelected: selected.id == ingredient.id,
            value: ingredient.id,
            text: ingredient.name,
          ),
      ]),
      OrderQuantityList(
        key: quantityList,
        ingredient: selected,
        selected: quantityId,
      ),
    ]);
  }

  @override
  void dispose() {
    OrderProduct.removeListener(
      _listener,
      OrderProductListenerTypes.selection,
    );
    super.dispose();
  }

  String? getSelectedQuantityId(ProductIngredient ingredient) {
    return Cart.instance.getSelectedQuantityId(ingredient);
  }

  @override
  void initState() {
    super.initState();
    OrderProduct.addListener(
      _listener,
      OrderProductListenerTypes.selection,
    );
  }

  Widget _emptyRows(BuildContext context, String ingredientMessage) {
    return _rowWrapper([
      SingleRowWrap(
        children: <Widget>[RadioText.empty(ingredientMessage)],
      ),
      SingleRowWrap(
        children: <Widget>[
          RadioText.empty(tt('order.list.wait_select_ingredient')),
        ],
      ),
    ]);
  }

  void _listener() => setState(() {});

  Widget _rowWrapper(List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}
