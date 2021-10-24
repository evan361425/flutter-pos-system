import 'package:flutter/material.dart';
import 'package:possystem/components/radio_text.dart';
import 'package:possystem/components/style/single_row_warp.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/models/repository/cart_ingredients.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';

class OrderIngredientList extends StatefulWidget {
  const OrderIngredientList({Key? key}) : super(key: key);

  @override
  _OrderIngredientListState createState() => _OrderIngredientListState();
}

class _OrderIngredientListState extends State<OrderIngredientList> {
  static const _INGREDIENT_RADIO_KEY = 'order.ingredients';

  final quantityList = GlobalKey<_OrderQuantityListState>();

  @override
  Widget build(BuildContext context) {
    final ingredients = context.watch<CartIngredients>();

    if (Cart.instance.isEmpty) {
      return _emptyRows(context, 'cart_empty');
    }

    if (!Cart.instance.isSameProducts) {
      return _emptyRows(context, 'not_same_product');
    }

    ingredients.setIngredients(Cart.instance.selected.first.product);
    if (ingredients.isEmpty) {
      return _emptyRows(context, 'no_quantity');
    }

    final ingredientId = ingredients.selected!.id;
    final quantityId = ingredients.getSelectedQuantityId();
    quantityList.currentState?.update(quantityId);

    return _rowWrapper([
      SingleRowWrap(children: <Widget>[
        for (final ingredient in ingredients.ingredients)
          RadioText(
            key: Key('order.ingredient.${ingredient.id}'),
            onSelected: (_) {
              ingredients.selectIngredient(ingredient);
              quantityList.currentState
                  ?.update(ingredients.getSelectedQuantityId());
            },
            groupId: _INGREDIENT_RADIO_KEY,
            isSelected: ingredientId == ingredient.id,
            value: ingredient.id,
            text: ingredient.name,
          ),
      ]),
      _OrderQuantityList(
        key: quantityList,
        selected: quantityId,
      ),
    ]);
  }

  Widget _emptyRows(BuildContext context, String key) {
    return _rowWrapper([
      SingleRowWrap(
        key: Key('order.ingredient.$key'),
        children: <Widget>[RadioText.empty(tt('order.list.$key'))],
      ),
      SingleRowWrap(
        children: <Widget>[
          RadioText.empty(tt('order.list.wait_select_ingredient')),
        ],
      ),
    ]);
  }

  Widget _rowWrapper(List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

class _OrderQuantityList extends StatefulWidget {
  final String? selected;

  const _OrderQuantityList({
    Key? key,
    required this.selected,
  }) : super(key: key);

  @override
  State<_OrderQuantityList> createState() => _OrderQuantityListState();
}

class _OrderQuantityListState extends State<_OrderQuantityList> {
  static const _QUANTITY_RADIO_KEY = 'order.quantities';

  String? selected;

  @override
  Widget build(BuildContext context) {
    return SingleRowWrap(children: <Widget>[
      RadioText(
        key: Key('order.quantity.default'),
        onSelected: (_) => CartIngredients.instance.selectQuantity(null),
        groupId: _QUANTITY_RADIO_KEY,
        value: '',
        isSelected: null == selected,
        text: tt(
          'order.list.default_quantity',
          {'amount': CartIngredients.instance.selected!.amount},
        ),
      ),
      for (final quantity in CartIngredients.instance.selected!.items)
        RadioText(
          key: Key('order.quantity.${quantity.id}'),
          onSelected: (_) => select(quantity.id),
          groupId: _QUANTITY_RADIO_KEY,
          value: quantity.id,
          isSelected: quantity.id == selected,
          text: '${quantity.name}（${quantity.amount}）',
        ),
    ]);
  }

  @override
  void initState() {
    selected = widget.selected;
    super.initState();
  }

  void select(String quantityId) {
    selected = quantityId;
    CartIngredients.instance.selectQuantity(quantityId);
  }

  void update(String? selected) {
    if (selected != this.selected) {
      setState(() {
        this.selected = selected;
      });
    }
  }
}
