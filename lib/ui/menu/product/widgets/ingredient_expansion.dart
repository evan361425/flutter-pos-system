import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/icon_text.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

class IngredientExpansion extends StatefulWidget {
  final List<ProductIngredient> ingredients;

  IngredientExpansion({Key? key, required this.ingredients}) : super(key: key);

  @override
  _IngredientExpansionState createState() => _IngredientExpansionState();
}

enum _Actions {
  delete,
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

  Widget _addButtons(ProductIngredient ingredient) {
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

  ExpansionPanel _panelBuilder(int index, ProductIngredient ingredient) {
    final body = ingredient.items.map<Widget>((quantity) {
      return ListTile(
        onTap: () => Navigator.of(context).pushNamed(
          Routes.menuQuantity,
          arguments: quantity,
        ),
        title: Text(quantity.name),
        trailing: Text(quantity.amount.toString()),
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
        onLongPress: () => BottomSheetActions.withDelete<_Actions>(
          context,
          deleteValue: _Actions.delete,
          warningContent: Text(tt('delete_confirm', {'name': ingredient.name})),
          deleteCallback: ingredient.remove,
        ),
        child: ListTile(
          title: Text(ingredient.name),
          subtitle:
              Text(tt('menu.ingredient.amount', {'amount': ingredient.amount})),
        ),
      ),
      isExpanded: showIngredient[index],
      body: Column(children: body),
    );
  }

  Widget _quantityMetadata(ProductQuantity quantity) {
    return Row(
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
