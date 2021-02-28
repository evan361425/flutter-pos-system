import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:possystem/components/icon_text.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/models.dart';
import 'package:possystem/ui/menu/product/widgets/widgets.dart';
import 'package:provider/provider.dart';

class IngredientExpansion extends StatefulWidget {
  IngredientExpansion({
    Key key,
    @required Map<String, IngredientModel> ingredients,
  })  : ingredients = ingredients.values.toList(),
        super(key: key);

  final List<IngredientModel> ingredients;

  @override
  _IngredientExpansionState createState() => _IngredientExpansionState();
}

class _IngredientExpansionState extends State<IngredientExpansion> {
  List<bool> showIngredient;

  @override
  void initState() {
    showIngredient = List.filled(widget.ingredients.length, false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ExpansionPanelList(
        children: widget.ingredients
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

  ExpansionPanel _panelBuilder(int index, IngredientModel ingredient) {
    final body = ingredient.additionalSets.values.map<Widget>((ingredientSet) {
      return ListTile(
        onTap: () {
          goToIngredientSetModel(ingredientSet, ingredient);
        },
        title: Text(ingredientSet.name),
        trailing: Text('${ingredientSet.ammount}'),
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
        title: Text(ingredient.name),
        subtitle: Text('使用量：${ingredient.defaultAmount}'),
      ),
      body: Column(
        children: body,
      ),
      isExpanded: showIngredient[index],
    );
  }

  Widget _addButtons(IngredientModel ingredient) {
    return Row(children: [
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: RaisedButton.icon(
            color: Theme.of(context).secondaryHeaderColor,
            icon: Icon(Icons.settings_sharp),
            label: Text('設定成份資料'),
            onPressed: () {
              final product = context.read<ProductModel>();
              Navigator.of(context).push(CupertinoPageRoute(
                builder: (_) => IngredientModal(
                  product: product,
                  ingredient: ingredient,
                ),
              ));
            },
          ),
        ),
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: RaisedButton.icon(
            icon: Icon(Icons.add),
            label: Text('新增特殊份量'),
            onPressed: () {
              goToIngredientSetModel(IngredientSet(name: ''), ingredient);
            },
          ),
        ),
      ),
    ]);
  }

  Widget _ingredientSetMetadata(IngredientSet ingredientSet) {
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
      padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
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
    IngredientSet ingredientSet,
    IngredientModel ingredient,
  ) {
    final product = context.read<ProductModel>();
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => IngredientSetModal(
          ingredientSet: ingredientSet,
          ingredient: ingredient,
          product: product,
        ),
      ),
    );
  }
}
