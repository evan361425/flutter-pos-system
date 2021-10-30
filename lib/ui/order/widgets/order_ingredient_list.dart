import 'package:flutter/material.dart';
import 'package:possystem/components/radio_text.dart';
import 'package:possystem/components/style/single_row_warp.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/models/repository/cart_ingredients.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';

class OrderIngredientList extends StatelessWidget {
  static const _ingredientRadioKey = 'order.ingredients';

  const OrderIngredientList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ingredients = context.watch<CartIngredients>();

    if (Cart.instance.isEmpty) {
      return _emptyRows('cart_empty');
    }

    if (!Cart.instance.isSameProducts) {
      return _emptyRows('not_same_product');
    }

    ingredients.setIngredients(Cart.instance.selected.first.product);
    if (ingredients.isEmpty) {
      return _emptyRows('no_quantity');
    }

    final ingredientId = ingredients.selected!.id;
    final quantityId = ingredients.getSelectedQuantityId();
    final quantityList = GlobalKey<_OrderQuantityListState>();

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
            groupId: _ingredientRadioKey,
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

  Widget _emptyRows(String key) {
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
  static const _quantityRadioKey = 'order.quantities';

  String? selected;

  @override
  Widget build(BuildContext context) {
    return SingleRowWrap(children: <Widget>[
      RadioText(
        key: const Key('order.quantity.default'),
        onSelected: (_) => CartIngredients.instance.selectQuantity(null),
        groupId: _quantityRadioKey,
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
          groupId: _quantityRadioKey,
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
