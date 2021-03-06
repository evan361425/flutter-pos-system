import 'package:flutter/material.dart';
import 'package:possystem/components/style/custom_styles.dart';
import 'package:possystem/components/style/icon_filled_button.dart';
import 'package:possystem/components/style/icon_text.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/slidable_item_list.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/repository/menu_model.dart';
import 'package:possystem/models/stock/ingredient_model.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

class IngredientList extends StatelessWidget {
  final List<IngredientModel> ingredients;

  const IngredientList({Key? key, required this.ingredients}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SlidableItemList<IngredientModel>(
      items: ingredients,
      handleDelete: (_, ingredient) =>
          MenuModel.instance.removeIngredients(ingredient.id),
      handleTap: _handleTap,
      warningContextBuilder: _warningContextBuilder,
      tileBuilder: _tileBuilder,
    );
  }

  void _handleTap(BuildContext context, IngredientModel ingredient) {
    Navigator.of(context).pushNamed(
      Routes.stockIngredient,
      arguments: ingredient,
    );
  }

  Future<num?> _showTextDialog(
    BuildContext context, {
    String? defaultValue,
    required String title,
  }) async {
    final controller = TextEditingController(text: defaultValue);
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        final action = (String value) {
          if (formKey.currentState!.validate()) {
            Navigator.of(context).pop<String>(value);
          }
        };

        return AlertDialog(
          title: Text(title),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.number,
              validator: Validator.positiveNumber(''),
              onFieldSubmitted: action,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop<String>(controller.text);
                }
              },
              child: Text(tt('save')),
            ),
          ],
        );
      },
    );

    return result == null ? null : num.tryParse(result);
  }

  Widget _tileBuilder(BuildContext context, IngredientModel ingredient) {
    final theme = Theme.of(context);

    Future<void> updateAmount(num? amount) async {
      if (amount != null) {
        await ingredient.addAmount(amount);
      }
    }

    Future<void> onAddAmount() async {
      final result = await _showTextDialog(
        context,
        defaultValue: ingredient.lastAddAmount?.toString(),
        title: tt('stock.add_amount', {'name': ingredient.name}),
      );

      await updateAmount(result);
    }

    Future<void> onMinusAmount() async {
      final result = await _showTextDialog(
        context,
        title: tt('stock.minus_amount', {'name': ingredient.name}),
      );

      await updateAmount(result == null ? null : -result);
    }

    return ListTile(
      title: Text(
        ingredient.name,
        style: theme.textTheme.headline6,
      ),
      subtitle: Row(
        children: <Widget>[
          IconText(
            text: ingredient.currentAmount?.toString() ??
                tt('stock.ingredient.unset'),
            icon: Icons.store_sharp,
            textStyle: theme.textTheme.muted,
          ),
          MetaBlock(),
          IconText(
            text: ingredient.lastAmount?.toString() ??
                tt('stock.ingredient.un_add'),
            icon: Icons.shopping_cart_sharp,
            textStyle: theme.textTheme.muted,
          ),
        ],
      ),
      trailing: Wrap(
        spacing: kSpacing1,
        children: <Widget>[
          IconFilledButton(
            onPressed: onAddAmount,
            icon: KIcons.add,
          ),
          IconFilledButton(
            onPressed: onMinusAmount,
            icon: KIcons.remove,
          ),
        ],
      ),
    );
  }

  Widget _warningContextBuilder(
      BuildContext context, IngredientModel ingredient) {
    final count = MenuModel.instance.getIngredients(ingredient.id).length;

    if (count == 0) {
      return Text(tt('delete_confirm', {'name': ingredient.name}));
    }

    return Text(tt(
      'stock.ingredient.delete_confirm',
      {'name': ingredient.name, 'count': count},
    ));
  }
}
