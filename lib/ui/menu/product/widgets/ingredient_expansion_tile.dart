import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/menu/product/widgets/ingredient_expansion_actions.dart';
import 'package:possystem/ui/menu/product/widgets/ingredient_quantity_metadata.dart';
import 'package:possystem/ui/menu/product/widgets/ingredient_quantity_tile.dart';

class IngredientExpansionTile extends StatelessWidget {
  final ProductIngredient ingredient;

  const IngredientExpansionTile({
    Key? key,
    required this.ingredient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: GestureDetector(
        onLongPress: () => BottomSheetActions.withDelete<_Actions>(
          context,
          deleteValue: _Actions.delete,
          warningContent: Text(tt('delete_confirm', {'name': ingredient.name})),
          deleteCallback: ingredient.remove,
        ),
        child: Text(ingredient.name),
      ),
      subtitle: Text(
        tt('menu.ingredient.amount', {'amount': ingredient.amount}),
      ),
      children: [
        if (ingredient.isNotEmpty) IngredientQuantityMetadata(),
        ...ingredient.items.map<Widget>(
          (quantity) => IngredientQuantityTile(quantity: quantity),
        ),
        IngredientExpansionActions(ingredient: ingredient),
      ],
    );
  }
}

enum _Actions {
  delete,
}
