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
    final cart = context.watch<Cart>();
    final ingredients = context.watch<CartIngredients>();

    if (cart.isEmpty) {
      return _emptyRows(context, tt('order.list.cart_empty'));
    }

    if (!cart.isSameProducts) {
      return _emptyRows(context, tt('order.list.not_same_product'));
    }

    ingredients.setIngredients(cart.selected.first.product);
    if (ingredients.isEmpty) {
      return _emptyRows(context, tt('order.list.no_quantity'));
    }

    final ingredientId = ingredients.selected!.id;
    final quantityId = ingredients.getSelectedQuantityId();
    quantityList.currentState?.update(quantityId);

    return _rowWrapper([
      SingleRowWrap(children: <Widget>[
        for (final ingredient in ingredients.ingredients)
          RadioText(
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
          onSelected: (_) {
            selected = quantity.id;
            CartIngredients.instance.selectQuantity(quantity.id);
          },
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
