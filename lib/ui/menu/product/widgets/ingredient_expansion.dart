import 'package:flutter/material.dart';
import 'package:possystem/components/icon_text.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/menu/product_ingredient_model.dart';
import 'package:possystem/models/menu/product_quantity_model.dart';
import 'package:possystem/models/menu/product_model.dart';
import 'package:possystem/ui/menu/menu_routes.dart';
import 'package:provider/provider.dart';

import 'quantity_modal.dart';

class IngredientExpansion extends StatefulWidget {
  IngredientExpansion({Key key}) : super(key: key);

  @override
  _IngredientExpansionState createState() => _IngredientExpansionState();
}

class _IngredientExpansionState extends State<IngredientExpansion> {
  List<bool> showIngredient = [];
  List<ProductIngredientModel> ingredients;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ingredients = context.watch<ProductModel>().ingredients.values.toList();

    // Make old expansion still opening when rebuilding
    for (var i = showIngredient.length; i < ingredients.length; i++) {
      showIngredient.add(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ExpansionPanelList(
        children: ingredients
            .asMap()
            .map((index, ingredient) {
              return MapEntry(index, _panelBuilder(index, ingredient));
            })
            .values
            .toList(),
        expansionCallback: (int index, bool status) {
          setState(() {
            showIngredient[index] = !showIngredient[index];
          });
        },
      ),
    );
  }

  ExpansionPanel _panelBuilder(int index, ProductIngredientModel ingredient) {
    final body = ingredient.quantities.values.map<Widget>((quantity) {
      return ListTile(
        onTap: () => goToQuantityModel(quantity),
        title: Text(quantity.quantity.name),
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
      headerBuilder: (_, __) => ListTile(
        title: Text(ingredient.ingredient.name),
        subtitle: Text('使用量：${ingredient.amount}'),
      ),
      body: Column(
        children: body,
      ),
      isExpanded: showIngredient[index],
    );
  }

  Widget _addButtons(ProductIngredientModel ingredient) {
    return Row(children: [
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kPadding),
          child: ElevatedButton.icon(
            // color: Theme.of(context).secondaryHeaderColor,
            icon: Icon(Icons.settings_sharp),
            label: Text('設定成份資料'),
            onPressed: () {
              Navigator.of(context).pushNamed(
                MenuRoutes.productIngredient,
                arguments: ingredient,
              );
            },
          ),
        ),
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kPadding),
          child: ElevatedButton.icon(
            icon: Icon(KIcons.add),
            label: Text('新增特殊份量'),
            onPressed: () => goToQuantityModel(
              ProductQuantityModel(ingredient: ingredient),
            ),
          ),
        ),
      ),
    ]);
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
            iconName: 'loyalty_sharp',
          ),
        ),
        MetaBlock(),
        Tooltip(
          message: '額外成本',
          child: IconText(
            text: quantity.additionalCost.toString(),
            iconName: 'attach_money_sharp',
          ),
        ),
      ],
    );
  }

  Widget _quantityTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kPadding),
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

  void goToQuantityModel(ProductQuantityModel quantity) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuantityModal(quantity: quantity),
      ),
    );
  }
}
