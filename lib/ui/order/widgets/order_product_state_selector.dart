import 'package:flutter/material.dart';
import 'package:possystem/components/style/radio_text.dart';
import 'package:possystem/components/style/single_row_warp.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/models/repository/cart_ingredients.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';

class OrderProductStateSelector extends StatelessWidget {
  final quantityListState = GlobalKey<_OrderQuantityListState>();

  final ingredientListState = GlobalKey<_OrderIngredientListState>();

  OrderProductStateSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ingredients = context.watch<CartIngredients>();

    if (Cart.instance.isEmpty) {
      return _emptyRows('emptyCart');
    }

    if (!Cart.instance.isSameProducts) {
      return _emptyRows('differentProducts');
    }

    ingredients.selectIngredientBy(Cart.instance.selected.first.product);
    if (ingredients.isEmpty) {
      return _emptyRows('noNeedIngredient');
    }

    ingredientListState.currentState?.selectedId = ingredients.selectedId;
    quantityListState.currentState?.selectedId = ingredients.selectedQuantityId;

    return _rowWrapper([
      _OrderIngredientList(
        key: ingredientListState,
        onSelected: (ingredient) {
          ingredients.selectIngredient(ingredient);
          quantityListState.currentState
              ?.update(ingredients.selectedQuantityId);
        },
      ),
      _OrderQuantityList(key: quantityListState),
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
  final void Function(ProductIngredient) onSelected;

  const _OrderIngredientList({
    Key? key,
    required this.onSelected,
  }) : super(key: key);

  @override
  _OrderIngredientListState createState() => _OrderIngredientListState();
}

class _OrderIngredientListState extends State<_OrderIngredientList> {
  late String selectedId;

  @override
  Widget build(BuildContext context) {
    return SingleRowWrap(children: <Widget>[
      for (final ingredient in CartIngredients.instance.itemList)
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
  void didChangeDependencies() {
    selectedId = CartIngredients.instance.selectedId;
    super.didChangeDependencies();
  }
}

class _OrderQuantityList extends StatefulWidget {
  const _OrderQuantityList({Key? key}) : super(key: key);

  @override
  State<_OrderQuantityList> createState() => _OrderQuantityListState();
}

class _OrderQuantityListState extends State<_OrderQuantityList> {
  String? selectedId;

  @override
  Widget build(BuildContext context) {
    final ingredients = CartIngredients.instance;
    return SingleRowWrap(children: <Widget>[
      RadioText(
        key: const Key('order.quantity.default'),
        onChanged: (_) => select(null),
        isSelected: null == selectedId,
        text: S.orderCartQuantityDefault(ingredients.selectedAmount),
      ),
      for (final quantity in ingredients.quantityList)
        RadioText(
          key: Key('order.quantity.${quantity.id}'),
          onChanged: (_) => select(quantity.id),
          isSelected: quantity.id == selectedId,
          text: '${quantity.name}（${quantity.amount}）',
        ),
    ]);
  }

  @override
  void didChangeDependencies() {
    selectedId = CartIngredients.instance.selectedQuantityId;
    super.didChangeDependencies();
  }

  void select(String? quantityId) {
    CartIngredients.instance.selectQuantity(quantityId);
    setState(() => selectedId = quantityId);
  }

  void update(String? selectedId) {
    setState(() => this.selectedId = selectedId);
  }
}
