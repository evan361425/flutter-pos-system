import 'package:flutter/material.dart';
import 'package:possystem/components/style/custom_styles.dart';
import 'package:possystem/components/style/icon_filled_button.dart';
import 'package:possystem/components/style/icon_text.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/page/slidable_item_list.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/repository/menu_model.dart';
import 'package:possystem/models/stock/ingredient_model.dart';
import 'package:possystem/routes.dart';

class IngredientList extends StatelessWidget {
  final List<IngredientModel> ingredients;

  const IngredientList({Key? key, required this.ingredients}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SlidableItemList<IngredientModel>(
      items: ingredients,
      handleDelete: _handleDelete,
      handleTap: _handleTap,
      warningContextBuilder: _warningContextBuilder,
      tileBuilder: _tileBuilder,
    );
  }

  Future<void> _handleDelete(BuildContext context, IngredientModel ingredient) {
    return MenuModel.instance.removeIngredients(ingredient.id);
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
              onPressed: () => action(controller.text),
              child: Text('儲存'),
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
        title: '增加 ${ingredient.name} 的庫存',
      );

      await updateAmount(result);
    }

    Future<void> onMinusAmount() async {
      final result = await _showTextDialog(
        context,
        title: '減少 ${ingredient.name} 的庫存',
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
            text: ingredient.currentAmount?.toString() ?? '尚未設定',
            iconName: 'store_sharp',
            textStyle: theme.textTheme.muted,
          ),
          MetaBlock(),
          IconText(
            text: ingredient.lastAmount?.toString() ?? '尚未補貨',
            iconName: 'shopping_cart_sharp',
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
    final countText = count == 0
        ? TextSpan()
        : TextSpan(children: [
            TextSpan(text: '將會一同刪除掉 '),
            TextSpan(text: count.toString()),
            TextSpan(text: ' 個產品的成分\n\n'),
          ]);

    return RichText(
      text: TextSpan(
        text: '確定要刪除 ',
        children: [
          TextSpan(
            text: ingredient.name,
            style: TextStyle(color: kNegativeColor),
          ),
          TextSpan(text: ' 嗎？\n\n'),
          countText,
          TextSpan(text: '此動作將無法復原！'),
        ],
        style: Theme.of(context).textTheme.bodyText1,
      ),
    );
  }
}
