import 'package:flutter/material.dart';
import 'package:possystem/components/radio_text.dart';
import 'package:possystem/components/single_row_warp.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/helpers/custom_styles.dart';
import 'package:possystem/models/menu/product_ingredient_model.dart';
import 'package:possystem/models/order/order_ingredient_model.dart';
import 'package:possystem/models/order/order_product_model.dart';
import 'package:possystem/models/repository/cart_model.dart';

class IngredientSelection extends StatefulWidget {
  const IngredientSelection({Key? key}) : super(key: key);

  @override
  _IngredientSelectionState createState() => _IngredientSelectionState();
}

class _IngredientSelectionState extends State<IngredientSelection> {
  static const QUANTITY_GROUP = 'order.quantities';
  static const INGREDIENT_GROUP = 'order.ingredients';

  ProductIngredientModel? selectedIngredient;

  String? selectedQuantityId;

  @override
  Widget build(BuildContext context) {
    final product = CartModel.instance.selectedSameProduct?.first?.product;
    if (product == null) return _emptyWidget(context, '請選擇相同的產品來設定其成份');

    final ingredients = product.ingredientsWithQuantity;
    if (ingredients.isEmpty) return _emptyWidget(context, '該產品無可設定的成份');

    selectedIngredient ??= ingredients.first;
    selectedQuantityId = CartModel.instance.getSelectedQuantityId(
      selectedIngredient,
    );

    // uncheck all ratio if there has different between quantites
    if (selectedQuantityId == null) RadioText.clearSelected(QUANTITY_GROUP);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ingredientsRow(ingredients),
        _quantitiesRow(),
      ],
    );
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

  Widget _emptyWidget(BuildContext context, String ingredientMessage) {
    final textTheme = Theme.of(context).textTheme;
    Widget mockRadioText(String text) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.all(kSpacing2),
        child: Text(
          text,
          style: textTheme.bodyText1!.copyWith(color: textTheme.muted.color),
        ),
      );
    }

    selectedIngredient = null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleRowWrap(
          children: <Widget>[mockRadioText(ingredientMessage)],
        ),
        SingleRowWrap(
          children: <Widget>[mockRadioText('請選擇成份來設定份量')],
        ),
      ],
    );
  }

  Widget _ingredientsRow(Iterable<ProductIngredientModel> ingredients) {
    return SingleRowWrap(children: <Widget>[
      for (var ingredient in ingredients)
        RadioText(
          onSelected: () {
            setState(() => selectedIngredient = ingredient);
          },
          groupId: INGREDIENT_GROUP,
          value: ingredient.id,
          child: Text(ingredient.name),
        ),
    ]);
  }

  void _listener() {
    setState(() {});
  }

  Widget _quantitiesRow() {
    return SingleRowWrap(children: <Widget>[
      _quantityDefaultOption(),
      for (var quantity in selectedIngredient!.childs)
        RadioText(
          onSelected: () {
            final ingredient = OrderIngredientModel(
              ingredient: selectedIngredient!,
              quantity: quantity,
            );
            CartModel.instance.updateSelectedIngredient(ingredient);
          },
          groupId: QUANTITY_GROUP,
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
      groupId: 'order.quantities',
      value: CartModel.DEFAULT_QUANTITY_ID,
      isSelected: selectedQuantityId == CartModel.DEFAULT_QUANTITY_ID,
      child: Text('預設值（${selectedIngredient!.amount}）'),
    );
  }
}
