import 'package:flutter/material.dart';
import 'package:possystem/components/scaffold/fade_in_title.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/localizations.dart';
import 'package:possystem/models/product_model.dart';
import 'package:possystem/ui/menu/product/widgets/ingredient_expansion.dart';
import 'package:possystem/ui/menu/product/widgets/product_metadata.dart';

class ProductScreen extends StatelessWidget {
  final scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    final product = ProductModel.fromMap('Ham Burger', {
      'index': 1,
      'catalogName': 'Burger',
      'price': 50,
      'cost': 30,
      'ingredients': {
        'ing1': {
          'defaultAmount': 50,
          'additionalSets': {
            'more': {
              'additionalCost': 5,
              'additionalPrice': 10,
              'ammount': 100,
            },
            'none': {
              'additionalCost': -5,
              'additionalPrice': 0,
              'ammount': 0,
            },
          },
        },
        'ing2': {'defaultAmount': 20},
      },
    });

    return FadeInTitleScaffold(
      appBarLeading: IconButton(
        icon: Icon(Icons.arrow_back_ios_rounded),
        onPressed: () => print('hi'), //Navigator.of(context).pop(),
      ),
      appBarActions: [
        PopupMenuButton(
          icon: Icon(Icons.more_horiz),
          itemBuilder: (BuildContext context) {
            return <String>[
              'change',
              product.enable ? 'disable' : 'enable',
            ].map<PopupMenuItem<String>>((String value) {
              return PopupMenuItem<String>(
                value: value,
                child: Text(
                  Local.of(context).t('menu.product.actions.${value}'),
                ),
              );
            }).toList();
          },
          onSelected: (value) {},
        ),
      ],
      appBarTitle: product.name,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {},
        tooltip: Local.of(context).t('menu.product.add_integredient'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _productName(product, context),
                ProductMetadata(product: product),
              ],
            ),
          ),
          IngredientExpansion(ingredients: product.ingredients),
        ],
      ),
    );
  }

  Widget _productName(ProductModel product, BuildContext context) {
    return Text(
      product.name,
      style: Theme.of(context).textTheme.headline4,
    );
  }
}
