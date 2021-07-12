import 'package:flutter/material.dart';
import 'package:possystem/components/radio_text.dart';
import 'package:possystem/components/style/single_row_warp.dart';
import 'package:possystem/models/menu/product_ingredient_model.dart';
import 'package:possystem/models/order/order_ingredient_model.dart';
import 'package:possystem/models/order/order_product_model.dart';
import 'package:possystem/models/repository/cart_model.dart';
import 'package:possystem/translator.dart';

class OrderIngredientList extends StatefulWidget {
  const OrderIngredientList({Key? key}) : super(key: key);

  @override
  _OrderIngredientListState createState() => _OrderIngredientListState();
}

class _OrderIngredientListState extends State<OrderIngredientList> {
  static const _QUANTITY_RADIO_KEY = 'order.quantities';
  static const _INGREDIENT_RADIO_KEY = 'order.ingredients';

  ProductIngredientModel? selectedIngredient;

  String? selectedQuantityId;

  @override
  Widget build(BuildContext context) {
    if (CartModel.instance.isEmpty) {
      return _emptyRows(context, tt('order.list.cart_empty'));
    }
    if (!CartModel.instance.isSameProducts) {
      return _emptyRows(context, tt('order.list.not_same_product'));
    }

    final product = CartModel.instance.products.first.product;
    final ingredients = product.ingredientsWithQuantity;
    if (ingredients.isEmpty) {
      return _emptyRows(context, tt('order.list.no_quantity'));
    }

    selectedIngredient ??= ingredients.first;
    selectedQuantityId =
        CartModel.instance.getSelectedQuantityId(selectedIngredient!);

    return _rowWrapper([
      _ingredientsRow(ingredients),
      _quantitiesRow(),
    ]);
  }

  @override
  void dispose() {
    OrderProductModel.removeListener(
      _listener,
      OrderProductListenerTypes.selection,
    );
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    OrderProductModel.addListener(
      _listener,
      OrderProductListenerTypes.selection,
    );
  }

  Widget _emptyRows(BuildContext context, String ingredientMessage) {
    selectedIngredient = null;

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

  Widget _ingredientsRow(Iterable<ProductIngredientModel> ingredients) {
    return SingleRowWrap(children: <Widget>[
      for (var ingredient in ingredients)
        RadioText(
          onSelected: () {
            setState(() => selectedIngredient = ingredient);
          },
          groupId: _INGREDIENT_RADIO_KEY,
          value: ingredient.id,
          child: Text(ingredient.name),
        ),
    ]);
  }

  void _listener() => setState(() {});

  Widget _quantitiesRow() {
    RadioText.clearSelected(_QUANTITY_RADIO_KEY);

    return SingleRowWrap(children: <Widget>[
      _quantityDefaultOption(),
      for (final quantity in selectedIngredient!.items)
        RadioText(
          onSelected: () {
            final ingredient = OrderIngredientModel(
              ingredient: selectedIngredient!,
              quantity: quantity,
            );
            CartModel.instance.updateSelectedIngredient(ingredient);
          },
          groupId: _QUANTITY_RADIO_KEY,
          value: quantity.id,
          isSelected: quantity.id == selectedQuantityId,
          child: Text('${quantity.name}（${quantity.amount}）'),
        ),
    ]);
  }

  Widget _quantityDefaultOption() {
    return RadioText(
      onSelected: () {
        CartModel.instance.removeSelectedIngredient(selectedIngredient!.id);
      },
      groupId: _QUANTITY_RADIO_KEY,
      value: CartModel.DEFAULT_QUANTITY_ID,
      isSelected: selectedQuantityId == CartModel.DEFAULT_QUANTITY_ID,
      child: Text(tt(
        'order.list.default_quantity',
        {'amount': selectedIngredient!.amount},
      )),
    );
  }

  Widget _rowWrapper(List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}
