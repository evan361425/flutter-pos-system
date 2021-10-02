import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/dialog/delete_dialog.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/expansion_action_button.dart';
import 'package:possystem/components/style/icon_text.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

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
        if (ingredient.isNotEmpty) _IngredientQuantityMetadata(),
        ...ingredient.items.map<Widget>(
          (quantity) => _IngredientQuantityTile(quantity),
        ),
        _IngredientExpansionActions(ingredient),
      ],
    );
  }
}

enum _Actions {
  delete,
}

class _IngredientExpansionActions extends StatelessWidget {
  final ProductIngredient ingredient;

  const _IngredientExpansionActions(this.ingredient);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacing3),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        ExpansionActionButton(
          onPressed: () => Navigator.of(context).pushNamed(
            Routes.menuIngredient,
            arguments: ingredient,
          ),
          icon: Icon(KIcons.edit),
          label: Text(tt('menu.ingredient.edit')),
        ),
        ExpansionActionButton(
          onPressed: () => Navigator.of(context).pushNamed(
            Routes.menuQuantity,
            arguments: ingredient,
          ),
          icon: Icon(KIcons.add),
          label: Text(tt('menu.quantity.add')),
        ),
        ExpansionActionButton(
          isDanger: true,
          onPressed: () => DeleteDialog.show(
            context,
            deleteCallback: ingredient.remove,
            warningContent: Text(
              tt('delete_confirm', {'name': ingredient.name}),
            ),
          ),
          icon: Icon(KIcons.delete),
          label: Text('刪除成分'),
        ),
      ]),
    );
  }
}

class _IngredientQuantityMetadata extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacing3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(tt('menu.quantity.label.additional_price')),
              MetaBlock(),
              Text(tt('menu.quantity.label.additional_cost')),
            ],
          ),
          Text(tt('menu.quantity.label.amount')),
        ],
      ),
    );
  }
}

class _IngredientQuantityTile extends StatelessWidget {
  final ProductQuantity quantity;

  const _IngredientQuantityTile(this.quantity);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Navigator.of(context).pushNamed(
        Routes.menuQuantity,
        arguments: quantity,
      ),
      title: Text(quantity.name),
      trailing: Text(quantity.amount.toString()),
      onLongPress: () => BottomSheetActions.withDelete<_Actions>(
        context,
        deleteValue: _Actions.delete,
        warningContent: Text(tt('delete_confirm', {'name': quantity.name})),
        deleteCallback: quantity.remove,
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Tooltip(
            message: tt('menu.quantity.label.additional_price'),
            child: IconText(
              text: quantity.additionalPrice.toString(),
              icon: Icons.loyalty_sharp,
            ),
          ),
          MetaBlock(),
          Tooltip(
            message: tt('menu.quantity.label.additional_cost'),
            child: IconText(
              text: quantity.additionalCost.toString(),
              icon: Icons.attach_money_sharp,
            ),
          ),
        ],
      ),
    );
  }
}
