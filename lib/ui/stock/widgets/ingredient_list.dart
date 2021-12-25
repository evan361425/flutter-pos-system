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
    return SlidableItemList<Ingredient, int>(
      scrollable: false,
      delegate: SlidableItemDelegate(
        items: ingredients,
        deleteValue: 0,
        tileBuilder: (_, __, ingredient, ___) => _IngredientTile(ingredient),
        warningContextBuilder: _warningContextBuilder,
        handleDelete: _handleDelete,
        handleTap: _handleTap,
      ),
    );
  }

  Future<void> _handleDelete(Ingredient ingredient) async {
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
    final moreCtx = S.stockIngredientDialogDeletionContent(count);

    return Text(S.dialogDeletionContent(ingredient.name, moreCtx));
  }
}

class _IngredientTile extends StatelessWidget {
  final Ingredient ingredient;

  const _IngredientTile(this.ingredient);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: Key('stock.${ingredient.id}'),
      title: Text(ingredient.name),
      subtitle: MetaBlock.withString(context, <String>[
        '庫存：${ingredient.currentAmount ?? '無'}',
        '紀錄：${ingredient.lastAmount ?? '無'}',
      ]),
      trailing: Wrap(
        spacing: kSpacing1,
        children: <Widget>[
          IconFilledButton(
            key: Key('stock.${ingredient.id}.plus'),
            onPressed: () => _showTextDialog(
              context,
              initialValue: ingredient.lastAddAmount?.toString(),
              title: S.stockIngredientDialogIncrementTitle(ingredient.name),
            ).then((value) {
              if (value != null) ingredient.addAmount(value);
            }),
            icon: KIcons.add,
          ),
          IconFilledButton(
            key: Key('stock.${ingredient.id}.minus'),
            onPressed: () => _showTextDialog(
              context,
              title: S.stockIngredientDialogDecrementTitle(ingredient.name),
            ).then((value) {
              if (value != null) ingredient.addAmount(-value);
            }),
            icon: KIcons.remove,
          ),
        ],
      ),
    );
  }

  Future<num?> _showTextDialog(
    BuildContext context, {
    String? initialValue,
    required String title,
  }) async {
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => SingleTextDialog(
        title: Text(title),
        initialValue: initialValue ?? '0',
        validator: Validator.positiveNumber(''),
        selectAll: true,
        keyboardType: TextInputType.number,
      ),
    );

    return result == null ? null : num.tryParse(result);
  }
}
