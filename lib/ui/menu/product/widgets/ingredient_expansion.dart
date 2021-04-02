import 'package:flutter/material.dart';
import 'package:possystem/components/icon_text.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/ingredient_set_index_model.dart';
import 'package:possystem/models/product_ingredient_model.dart';
import 'package:possystem/models/product_ingredient_set_model.dart';
import 'package:possystem/models/product_model.dart';
import 'package:possystem/models/stock_model.dart';
import 'package:provider/provider.dart';

import 'ingredient_modal.dart';
import 'ingredient_set_modal.dart';

class IngredientExpansion extends StatefulWidget {
  IngredientExpansion({Key key}) : super(key: key);

  @override
  _IngredientExpansionState createState() => _IngredientExpansionState();
}

class _IngredientExpansionState extends State<IngredientExpansion> {
  List<bool> showIngredient = [];
  List<ProductIngredientModel> ingredients;
  StockModel stock;
  IngredientSetIndexModel ingredientSetIndex;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ingredients = context.watch<ProductModel>().ingredients.values.toList();
    stock = context.watch<StockModel>();
    ingredientSetIndex = context.watch<IngredientSetIndexModel>();

    // Don't rebuild make old expansion still opening
    for (var i = showIngredient.length; i < ingredients.length; i++) {
      showIngredient.add(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (ingredientSetIndex.isNotReady) return CircularProgressIndicator();

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
    final body = ingredient.ingredientSets.values.map<Widget>((ingredientSet) {
      return ListTile(
        onTap: () => goToIngredientSetModel(ingredient, ingredientSet),
        title: Text(ingredientSetIndex[ingredientSet.id].name),
        trailing: Text('${ingredientSet.amount}'),
        subtitle: _ingredientSetMetadata(ingredientSet),
      );
    }).toList();

    // prepend first row as title
    if (body.isNotEmpty) {
      body.insert(0, _ingredientSetTitle());
    }

    // append add bottom
    body.add(_addButtons(ingredient));

    return ExpansionPanel(
      canTapOnHeader: true,
      headerBuilder: (_, __) => ListTile(
        title: Text(stock[ingredient.id].name),
        subtitle: Text('使用量：${ingredient.defaultAmount}'),
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
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => IngredientModal(
                  ingredient: ingredient,
                  ingredientName: ingredientSetIndex[ingredient.id].name,
                ),
              ));
            },
          ),
        ),
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kPadding),
          child: ElevatedButton.icon(
            icon: Icon(Icons.add),
            label: Text('新增特殊份量'),
            onPressed: () {
              goToIngredientSetModel(
                ingredient,
                ProductIngredientSetModel.empty(),
              );
            },
          ),
        ),
      ),
    ]);
  }

  Widget _ingredientSetMetadata(ProductIngredientSetModel ingredientSet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Tooltip(
          message: '額外售價',
          child: IconText(
            text: ingredientSet.additionalPrice.toString(),
            iconName: 'loyalty_sharp',
          ),
        ),
        MetaBlock(),
        Tooltip(
          message: '額外成本',
          child: IconText(
            text: ingredientSet.additionalCost.toString(),
            iconName: 'attach_money_sharp',
          ),
        ),
      ],
    );
  }

  Widget _ingredientSetTitle() {
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

  void goToIngredientSetModel(
    ProductIngredientModel ingredient,
    ProductIngredientSetModel ingredientSet,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => IngredientSetModal(
          ingredientSet: ingredientSet,
          ingredient: ingredient,
          ingredientSetName: ingredientSetIndex[ingredientSet.id]?.name ?? '',
        ),
      ),
    );
  }
}
