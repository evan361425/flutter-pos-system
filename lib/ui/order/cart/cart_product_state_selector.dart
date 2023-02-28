import 'package:flutter/material.dart';
import 'package:possystem/components/style/single_row_warp.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/models/repository/cart_ingredients.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';

class CartProductStateSelector extends StatelessWidget {
  final quantityListState = GlobalKey<_QuantityListState>();

  final ingredientListState = GlobalKey<_IngredientListState>();

  CartProductStateSelector({Key? key}) : super(key: key);

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
      _IngredientList(
        key: ingredientListState,
        onSelected: (ingredient) {
          ingredients.selectIngredient(ingredient);
          quantityListState.currentState
              ?.update(ingredients.selectedQuantityId);
        },
      ),
      _QuantityList(key: quantityListState),
    ]);
  }

  Widget _emptyRows(String status) {
    return _rowWrapper([
      SingleRowWrap(
        key: Key('order.ingredient.$status'),
        children: <Widget>[
          ChoiceChip(
            selected: false,
            label: Text(S.orderCartIngredientStatus(status)),
          ),
        ],
      ),
      SingleRowWrap(
        children: <Widget>[
          ChoiceChip(
            selected: false,
            label: Text(S.orderCartQuantityNotAble),
          ),
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

class _IngredientList extends StatefulWidget {
  final void Function(ProductIngredient) onSelected;

  const _IngredientList({
    Key? key,
    required this.onSelected,
  }) : super(key: key);

  @override
  State<_IngredientList> createState() => _IngredientListState();
}

class _IngredientListState extends State<_IngredientList> {
  late String selectedId;

  @override
  Widget build(BuildContext context) {
    return SingleRowWrap(children: <Widget>[
      for (final ingredient in CartIngredients.instance.itemList)
        ChoiceChip(
          key: Key('order.ingredient.${ingredient.id}'),
          selected: selectedId == ingredient.id,
          onSelected: (selected) {
            if (selected) {
              setState(() => selectedId = ingredient.id);
              widget.onSelected(ingredient);
            }
          },
          label: Text(ingredient.name),
        ),
    ]);
  }

  @override
  void didChangeDependencies() {
    selectedId = CartIngredients.instance.selectedId;
    super.didChangeDependencies();
  }
}

class _QuantityList extends StatefulWidget {
  const _QuantityList({Key? key}) : super(key: key);

  @override
  State<_QuantityList> createState() => _QuantityListState();
}

class _QuantityListState extends State<_QuantityList> {
  String? selectedId;

  @override
  Widget build(BuildContext context) {
    final ingredients = CartIngredients.instance;
    return SingleRowWrap(children: <Widget>[
      ChoiceChip(
        key: const Key('order.quantity.default'),
        onSelected: (_) => select(null),
        // if pop from stash, it will be empty string
        selected: null == selectedId || selectedId == '',
        label: Text(S.orderCartQuantityDefault(ingredients.selectedAmount)),
      ),
      for (final quantity in ingredients.quantityList)
        ChoiceChip(
          key: Key('order.quantity.${quantity.id}'),
          onSelected: (_) => select(quantity.id),
          selected: quantity.id == selectedId,
          label: Text('${quantity.name}（${quantity.amount}）'),
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
