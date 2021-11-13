import 'package:flutter/material.dart';
import 'package:possystem/components/style/radio_text.dart';
import 'package:possystem/components/style/single_row_warp.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/models/repository/cart_ingredients.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';

class OrderProductStateSelector extends StatelessWidget {
  const OrderProductStateSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ingredients = context.watch<CartIngredients>();

    if (Cart.instance.isEmpty) {
      return _emptyRows('emptyCart');
    }

    if (!Cart.instance.isSameProducts) {
      return _emptyRows('differentProducts');
    }

    ingredients.setIngredients(Cart.instance.selected.first.product);
    if (ingredients.ingredients.isEmpty) {
      return _emptyRows('noNeedIngredient');
    }

    final ingredientId = ingredients.selected!.id;
    final quantityList = GlobalKey<_OrderQuantityListState>();

    return _rowWrapper([
      _OrderIngredientList(
        onSelected: (ingredient) {
          ingredients.selectIngredient(ingredient);
          quantityList.currentState
              ?.update(ingredients.getSelectedQuantityId());
        },
        ingredients: ingredients.ingredients,
        selectedId: ingredientId,
      ),
      _OrderQuantityList(
        key: quantityList,
        selectedId: ingredients.getSelectedQuantityId(),
      ),
    ]);
  }

  Widget _emptyRows(String status) {
    return _rowWrapper([
      SingleRowWrap(
        key: Key('order.ingredient.$status'),
        children: <Widget>[
          RadioText.empty(S.orderCartIngredientStatus(status)),
        ],
      ),
      SingleRowWrap(
        children: <Widget>[
          RadioText.empty(S.orderCartQuantityNotAble),
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

class _OrderIngredientList extends StatefulWidget {
  final List<ProductIngredient> ingredients;

  final String selectedId;

  final void Function(ProductIngredient) onSelected;

  const _OrderIngredientList({
    Key? key,
    required this.onSelected,
    required this.ingredients,
    required this.selectedId,
  }) : super(key: key);

  @override
  _OrderIngredientListState createState() => _OrderIngredientListState();
}

class _OrderIngredientListState extends State<_OrderIngredientList> {
  late String selectedId;

  @override
  Widget build(BuildContext context) {
    return SingleRowWrap(children: <Widget>[
      for (final ingredient in widget.ingredients)
        RadioText(
          key: Key('order.ingredient.${ingredient.id}'),
          isSelected: selectedId == ingredient.id,
          onChanged: (_) {
            setState(() => selectedId = ingredient.id);
            widget.onSelected(ingredient);
          },
          text: ingredient.name,
        ),
    ]);
  }

  @override
  void initState() {
    super.initState();
    selectedId = widget.selectedId;
  }
}

class _OrderQuantityList extends StatefulWidget {
  final String? selectedId;

  const _OrderQuantityList({
    Key? key,
    required this.selectedId,
  }) : super(key: key);

  @override
  State<_OrderQuantityList> createState() => _OrderQuantityListState();
}

class _OrderQuantityListState extends State<_OrderQuantityList> {
  String? selectedId;

  @override
  Widget build(BuildContext context) {
    return SingleRowWrap(children: <Widget>[
      RadioText(
        key: const Key('order.quantity.default'),
        onChanged: (_) => select(null),
        isSelected: null == selectedId,
        text: S.orderCartQuantityDefault(
          CartIngredients.instance.selected!.amount,
        ),
      ),
      for (final quantity in CartIngredients.instance.selected!.items)
        RadioText(
          key: Key('order.quantity.${quantity.id}'),
          onChanged: (_) => select(quantity.id),
          isSelected: quantity.id == selectedId,
          text: '${quantity.name}（${quantity.amount}）',
        ),
    ]);
  }

  @override
  void initState() {
    selectedId = widget.selectedId;
    super.initState();
  }

  void select(String? quantityId) {
    CartIngredients.instance.selectQuantity(quantityId);
    setState(() => selectedId = quantityId);
  }

  void update(String? selected) {
    if (selected != selectedId) {
      setState(() => selectedId = selected);
    }
  }
}
