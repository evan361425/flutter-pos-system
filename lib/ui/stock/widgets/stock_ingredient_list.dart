import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/dialog/slider_text_dialog.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/percentile_bar.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

class StockIngredientList extends StatelessWidget {
  final List<Ingredient> ingredients;

  const StockIngredientList({Key? key, required this.ingredients})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final updatedAt = latestUpdatedAt();

    return Column(
      children: [
        Center(
          child: HintText([
            updatedAt == null
                ? S.stockHasNotReplenishEver
                : S.stockUpdatedAt(updatedAt),
            S.totalCount(ingredients.length),
          ].join(MetaBlock.string)),
        ),
        const SizedBox(height: 2.0),
        for (final item in ingredients) _IngredientTile(item),
        const SizedBox(height: 4.0),
      ],
    );
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
      onLongPress: () => showActions(context),
      onTap: () => editAmount(context),
      trailing: IconButton(
        key: Key('stock.${ingredient.id}.edit'),
        onPressed: () => context.pushNamed(
          Routes.ingredientModal,
          pathParameters: {'id': ingredient.id},
        ),
        icon: const Icon(KIcons.edit),
      ),
    );
  }

  void showActions(BuildContext context) {
    final count = Menu.instance.getIngredients(ingredient.id).length;
    final more = S.stockIngredientDialogDeletionContent(count);

    BottomSheetActions.withDelete(
      context,
      deleteValue: 0,
      warningContent: Text(S.dialogDeletionContent(ingredient.name, more)),
      deleteCallback: delete,
    );
  }

  Future<void> delete() async {
    await ingredient.remove();
    return Menu.instance.removeIngredients(ingredient.id);
  }

  Future<void> editAmount(BuildContext context) async {
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
}
