import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

class IngredientExpansionActions extends StatelessWidget {
  final ProductIngredient ingredient;

  const IngredientExpansionActions({
    Key? key,
    required this.ingredient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacing3),
      child: Row(children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(Icons.settings_sharp),
            label: Text(tt('menu.ingredient.edit')),
            onPressed: () => Navigator.of(context).pushNamed(
              Routes.menuIngredient,
              arguments: ingredient,
            ),
          ),
        ),
        const SizedBox(width: kSpacing2),
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(KIcons.add),
            label: Text(tt('menu.quantity.add')),
            onPressed: () => Navigator.of(context).pushNamed(
              Routes.menuQuantity,
              arguments: ingredient,
            ),
          ),
        ),
      ]),
    );
  }
}
