import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/dialog/delete_dialog.dart';
import 'package:possystem/components/style/icon_text.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/menu/product_ingredient_model.dart';
import 'package:possystem/models/menu/product_quantity_model.dart';
import 'package:possystem/routes.dart';

class IngredientExpansion extends StatefulWidget {
  IngredientExpansion({Key? key, required this.ingredients}) : super(key: key);

  final List<ProductIngredientModel> ingredients;

  @override
  _IngredientExpansionState createState() => _IngredientExpansionState();
}

class _IngredientExpansionState extends State<IngredientExpansion> {
  late List<bool> showIngredient;

  @override
  Widget build(BuildContext context) {
    final length = widget.ingredients.length;
    if (length != showIngredient.length) {
      showIngredient = List.filled(length, false);
    }
    return Container(
      child: ExpansionPanelList(
        expansionCallback: (int index, bool status) {
          setState(() => showIngredient[index] = !status);
        },
        children: [
          for (var i = 0; i < length; i++)
            _panelBuilder(i, widget.ingredients[i])
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    showIngredient = List.filled(widget.ingredients.length, false);
  }

  Widget _addButtons(ProductIngredientModel ingredient) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacing3),
      child: Row(children: [
        Expanded(
          child: ElevatedButton.icon(
            // color: Theme.of(context).secondaryHeaderColor,
            icon: Icon(Icons.settings_sharp),
            label: Text('設定成份資料'),
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
            label: Text('新增特殊份量'),
            onPressed: () => Navigator.of(context).pushNamed(
              Routes.menuQuantity,
              arguments: ingredient,
            ),
          ),
        ),
      ]),
    );
  }

  ExpansionPanel _panelBuilder(int index, ProductIngredientModel ingredient) {
    final body = ingredient.items.map<Widget>((quantity) {
      return ListTile(
        onTap: () => Navigator.of(context).pushNamed(
          Routes.menuQuantity,
          arguments: quantity,
        ),
        title: Text(quantity.name),
        trailing: Text('${quantity.amount}'),
        subtitle: _quantityMetadata(quantity),
      );
    }).toList();

    // prepend first row as title
    if (body.isNotEmpty) {
      body.insert(0, _quantityTitle());
    }

    // append add bottom
    body.add(_addButtons(ingredient));

    return ExpansionPanel(
      canTapOnHeader: true,
      headerBuilder: (_, __) => GestureDetector(
        onLongPress: () async {
          final result = await showCircularBottomSheet(
            context,
            actions: _actions(),
          );

          if (result == 'delete') {
            await showDialog(
              context: context,
              builder: (_) => DeleteDialog(
                  content: Text('此動作將無法復原'),
                  onDelete: (_) => ingredient.remove()),
            );
          }
        },
        child: ListTile(
          title: Text(ingredient.name),
          subtitle: Text('使用量：${ingredient.amount}'),
        ),
      ),
      isExpanded: showIngredient[index],
      body: Column(children: body),
    );
  }

  Widget _quantityMetadata(ProductQuantityModel quantity) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Tooltip(
          message: '額外售價',
          child: IconText(
            text: quantity.additionalPrice.toString(),
            icon: Icons.loyalty_sharp,
          ),
        ),
        MetaBlock(),
        Tooltip(
          message: '額外成本',
          child: IconText(
            text: quantity.additionalCost.toString(),
            icon: Icons.attach_money_sharp,
          ),
        ),
      ],
    );
  }

  Widget _quantityTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacing3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('額外售價'),
              MetaBlock(),
              Text('額外成本'),
            ],
          ),
          Text('使用量'),
        ],
      ),
    );
  }

  List<Widget> _actions() {
    return [
      ListTile(
        title: Text('刪除'),
        leading: Icon(KIcons.delete, color: kNegativeColor),
        onTap: () => Navigator.of(context).pop('delete'),
      )
    ];
  }
}
