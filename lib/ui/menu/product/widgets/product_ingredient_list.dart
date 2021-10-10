import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

class ProductIngredientList extends StatelessWidget {
  final List<ProductIngredient> ingredients;

  const ProductIngredientList(this.ingredients);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(kSpacing1),
        child: HintText(tt('total_count', {'count': ingredients.length})),
      ),
      for (final ingredient in ingredients) _IngredientTile(ingredient),
    ]);
  }
}

class _IngredientTile extends StatelessWidget {
  final ProductIngredient ingredient;

  const _IngredientTile(this.ingredient);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: Text(ingredient.name),
        subtitle: Text('使用量：${ingredient.amount}'),
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: kSpacing2),
            child: Row(children: [
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pushNamed(
                  Routes.menuQuantity,
                  arguments: ingredient,
                ),
                icon: const Icon(KIcons.add),
                label: Text(tt('menu.quantity.add')),
              ),
              IconButton(
                onPressed: () => showActions(context),
                icon: Icon(KIcons.more),
              )
            ]),
          ),
          for (final item in ingredient.items) _QuantityTile(item),
        ],
      ),
    );
  }

  void showActions(BuildContext context) {
    BottomSheetActions.withDelete<int>(
      context,
      deleteValue: 0,
      actions: <BottomSheetAction<int>>[
        BottomSheetAction(
          title: Text(tt('menu.ingredient.edit')),
          leading: Icon(Icons.text_fields_sharp),
          navigateRoute: Routes.menuIngredient,
          navigateArgument: ingredient,
        ),
      ],
      warningContent: Text(tt('delete_confirm', {'name': ingredient.name})),
      deleteCallback: () => ingredient.remove(),
    );
  }
}

class _QuantityTile extends StatelessWidget {
  final ProductQuantity quantity;

  const _QuantityTile(this.quantity);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(quantity.name, style: Theme.of(context).textTheme.headline6),
      subtitle: MetaBlock.withString(context, <String>[
        '額外使用量：${quantity.amount}',
        '額外售價：${quantity.additionalPrice}',
        '額外成本：${quantity.additionalCost}',
      ]),
      onLongPress: () => BottomSheetActions.withDelete<int>(
        context,
        deleteValue: 0,
        warningContent: Text(tt('delete_confirm', {'name': quantity.name})),
        deleteCallback: quantity.remove,
      ),
      onTap: () => Navigator.of(context).pushNamed(
        Routes.menuQuantity,
        arguments: quantity,
      ),
    );
  }
}
