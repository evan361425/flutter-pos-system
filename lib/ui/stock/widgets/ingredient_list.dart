import 'package:flutter/material.dart';
import 'package:possystem/components/dialog/slider_text_dialog.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/slidable_item_list.dart';
import 'package:possystem/components/style/percentile_bar.dart';
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
    final updatedAt = latestUpdatedAt();

    return SlidableItemList<Ingredient, int>(
      scrollable: false,
      hintText: [
        updatedAt == null
            ? S.stockHasNotReplenishEver
            : S.stockUpdatedAt(updatedAt),
        S.totalCount(ingredients.length),
      ].join(MetaBlock.string),
      delegate: SlidableItemDelegate(
        groupTag: 'stock.ingredient',
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

  Future<void> _handleTap(BuildContext context, Ingredient ingredient) async {
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => SliderTextDialog(
        title: Text(ingredient.name),
        value: ingredient.currentAmount.toDouble(),
        max: ingredient.maxAmount,
        decoration: InputDecoration(
          label: Text(S.stockIngredientAmountLabel),
          helperText: '若沒有設定最大庫存量，增加庫存會重設最大值。',
          helperMaxLines: 3,
        ),
        validator: Validator.positiveNumber(S.stockIngredientAmountLabel),
      ),
    );

    if (result != null) {
      await ingredient.setAmount(num.tryParse(result) ?? 0);
    }
  }

  Widget _warningContextBuilder(BuildContext context, Ingredient ingredient) {
    final count = Menu.instance.getIngredients(ingredient.id).length;
    final moreCtx = S.stockIngredientDialogDeletionContent(count);

    return Text(S.dialogDeletionContent(ingredient.name, moreCtx));
  }

  DateTime? latestUpdatedAt() {
    DateTime? latest;
    for (var ingredient in ingredients) {
      if (latest == null) {
        latest = ingredient.updatedAt;
      } else if (ingredient.updatedAt?.isAfter(latest) == true) {
        latest = ingredient.updatedAt;
      }
    }

    return latest;
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
      subtitle: PercentileBar(ingredient.currentAmount, ingredient.maxAmount),
      trailing: IconButton(
        key: Key('stock.${ingredient.id}.edit'),
        onPressed: () => Navigator.of(context).pushNamed(
          Routes.stockIngredient,
          arguments: ingredient,
        ),
        icon: const Icon(KIcons.edit),
      ),
    );
  }
}
