import 'package:flutter/material.dart';
import 'package:possystem/components/icon_filled_button.dart';
import 'package:possystem/components/icon_text.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/page/slidable_item_list.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helper/validator.dart';
import 'package:possystem/models/stock/ingredient_model.dart';
import 'package:possystem/models/repository/menu_model.dart';
import 'package:possystem/models/repository/stock_model.dart';
import 'package:possystem/ui/stock/ingredient/ingredient_screen.dart';
import 'package:provider/provider.dart';

class IngredientList extends StatelessWidget {
  const IngredientList({Key key, @required this.ingredients}) : super(key: key);

  final List<IngredientModel> ingredients;

  @override
  Widget build(BuildContext context) {
    return SlidableItemList<IngredientModel>(
      items: ingredients,
      onDelete: _onDelete,
      onTap: _onTap,
      warningContext: _warningContextBuild,
      tileBuilder: _tileBuilder,
    );
  }

  Widget _tileBuilder(BuildContext context, IngredientModel ingredient) {
    final theme = Theme.of(context);

    void updateAmount(double amount) {
      if (amount != null) {
        ingredient.addAmount(amount);
        context.read<StockModel>()?.changedIngredient();
      }
    }

    Future<void> onAddAmount() async {
      final result = await _showTextDialog(
        context,
        defaultValue: ingredient.lastAddAmount?.toString(),
        title: '增加 ${ingredient.name} 的庫存',
      );

      updateAmount(result);
    }

    Future<void> onMinusAmount() async {
      final result = await _showTextDialog(
        context,
        title: '減少 ${ingredient.name} 的庫存',
      );

      updateAmount(result == null ? null : -result);
    }

    return ListTile(
      title: Text(
        ingredient.name,
        style: theme.textTheme.headline6,
      ),
      subtitle: Row(
        children: <Widget>[
          IconText(
            text: ingredient.lastAmount?.toString() ?? '尚未補貨',
            iconName: 'shopping_cart_sharp',
            textStyle: theme.textTheme.caption,
          ),
          MetaBlock(),
          IconText(
            text: ingredient.currentAmount?.toString() ?? '尚未設定',
            iconName: 'store_sharp',
            textStyle: theme.textTheme.caption,
          ),
        ],
      ),
      trailing: Wrap(
        spacing: kMargin / 2,
        children: <Widget>[
          IconFilledButton(
            onPressed: onAddAmount,
            child: Icon(KIcons.add),
          ),
          IconFilledButton(
            onPressed: onMinusAmount,
            child: Icon(KIcons.remove),
          ),
        ],
      ),
    );
  }

  void _onDelete(BuildContext context, IngredientModel ingredient) {
    debugPrint('Delete ingredient - ${ingredient.id} : ${ingredient.name}');
    final stock = context.read<StockModel>();
    final menu = context.read<MenuModel>();

    stock.removeIngredient(ingredient.id);
    menu.removeIngredient(ingredient.id);
  }

  Widget _warningContextBuild(
      BuildContext context, IngredientModel ingredient) {
    final menu = context.read<MenuModel>();
    final productCount = menu.productContainsIngredient(ingredient.id).length;
    final productCountText = productCount == 0
        ? TextSpan()
        : TextSpan(children: [
            TextSpan(text: '將會一同刪除掉 '),
            TextSpan(text: productCount.toString()),
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
          productCountText,
          TextSpan(text: '此動作將無法復原！'),
        ],
        style: Theme.of(context).textTheme.bodyText1,
      ),
    );
  }

  Future<double> _showTextDialog(
    BuildContext context, {
    String defaultValue,
    @required String title,
  }) async {
    final controller = TextEditingController(text: defaultValue);
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        final action = (String value) {
          if (formKey.currentState.validate()) {
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
              validator: Validator.positiveDouble(''),
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

    return result == null ? null : double.parse(result);
  }

  void _onTap(BuildContext context, IngredientModel ingredient) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => IngredientScreen(
          ingredient: ingredient,
        ),
      ),
    );
  }
}
