import 'package:flutter/material.dart';
import 'package:possystem/components/dialog/single_text_dialog.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/slidable_item_list.dart';
import 'package:possystem/components/style/icon_filled_button.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

class IngredientList extends StatelessWidget {
  final List<Ingredient> ingredients;

  const IngredientList({Key? key, required this.ingredients}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SlidableItemList<Ingredient, _Action>(
      items: ingredients,
      deleteValue: _Action.delete,
      tileBuilder: (_, __, ingredient) => _IngredientTile(ingredient),
      warningContextBuilder: _warningContextBuilder,
      handleDelete: _handleDelete,
      handleTap: _handleTap,
    );
  }

  Future<void> _handleDelete(ingredient) async {
    await ingredient.remove();
    return Menu.instance.removeIngredients(ingredient.id);
  }

  void _handleTap(BuildContext context, Ingredient ingredient) {
    Navigator.of(context).pushNamed(
      Routes.stockIngredient,
      arguments: ingredient,
    );
  }

  Widget _warningContextBuilder(BuildContext context, Ingredient ingredient) {
    final count = Menu.instance.getIngredients(ingredient.id).length;

    if (count == 0) {
      return Text(tt('delete_confirm', {'name': ingredient.name}));
    }

    return Text(tt(
      'stock.ingredient.delete_confirm',
      {'name': ingredient.name, 'count': count},
    ));
  }
}

enum _Action {
  delete,
}

class _IngredientTile extends StatelessWidget {
  final Ingredient ingredient;

  const _IngredientTile(this.ingredient);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title:
          Text(ingredient.name, style: Theme.of(context).textTheme.headline6),
      subtitle: MetaBlock.withString(context, <String>[
        '庫存：${ingredient.currentAmount ?? '無'}',
        '紀錄：${ingredient.lastAmount ?? '無'}',
      ]),
      trailing: Wrap(
        spacing: kSpacing1,
        children: <Widget>[
          IconFilledButton(
            onPressed: () async {
              final result = await _showTextDialog(
                context,
                defaultValue: ingredient.lastAddAmount?.toString(),
                title: tt('stock.add_amount', {'name': ingredient.name}),
              );

              await _updateAmount(result);
            },
            icon: KIcons.add,
          ),
          IconFilledButton(
            onPressed: () async {
              final result = await _showTextDialog(
                context,
                title: tt('stock.minus_amount', {'name': ingredient.name}),
              );

              await _updateAmount(result == null ? null : -result);
            },
            icon: KIcons.remove,
          ),
        ],
      ),
    );
  }

  Future<num?> _showTextDialog(
    BuildContext context, {
    String? defaultValue,
    required String title,
  }) async {
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => SingleTextDialog(
        title: Text(title),
        validator: Validator.positiveNumber(''),
        keyboardType: TextInputType.number,
      ),
    );

    return result == null ? null : num.tryParse(result);
  }

  Future<void> _updateAmount(num? amount) async {
    if (amount != null) {
      await ingredient.addAmount(amount);
    }
  }
}
