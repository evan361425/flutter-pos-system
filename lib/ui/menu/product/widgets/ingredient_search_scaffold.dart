import 'dart:math';

import 'package:flutter/material.dart';
import 'package:possystem/components/card_tile.dart';
import 'package:possystem/components/scaffold/search_scaffold.dart';
import 'package:possystem/models/ingredient_model.dart';
import 'package:possystem/models/search_history_model.dart';
import 'package:possystem/models/stock_model.dart';
import 'package:provider/provider.dart';

class IngredientSearchScaffold extends StatelessWidget {
  IngredientSearchScaffold({Key key, this.text}) : super(key: key);

  static final String tag = 'menu.poduct.ingredient.search';
  final String text;
  final scaffold = GlobalKey<SearchScaffoldState>();
  final histories = SearchHistoryModel(SearchHistoryTypes.ingredient);

  @override
  Widget build(BuildContext context) {
    final stock = context.watch<StockModel>();
    var sortedIngredients = <IngredientModel>[];
    return SearchScaffold<IngredientModel>(
      key: scaffold,
      onChanged: (String text) async {
        if (text.isEmpty) {
          sortedIngredients = [];
          return [];
        }

        sortedIngredients = stock.ingredients.values
            .map<IngredientModel>((e) => e..setSimilarity(text))
            .toList()
            .where((element) => element.similarity > 0)
            .toList()
              // if ing1 < ing2 return -1 will make ing1 be the first one
              ..sort((ing1, ing2) {
                if (ing1.similarity == ing2.similarity) return 0;
                return ing1.similarity < ing2.similarity ? 1 : -1;
              });
        final end = min(10, sortedIngredients.length);
        return sortedIngredients.sublist(0, end);
      },
      itemBuilder: _itemBuilder,
      emptyBuilder: _emptyBuilder,
      initialBuilder: _initialBuilder,
      heroTag: IngredientSearchScaffold.tag,
      text: text,
      hintText: '成份名稱，起司',
      textCapitalization: TextCapitalization.words,
    );
  }

  Widget _itemBuilder(BuildContext context, dynamic ingredient) {
    return CardTile(
      title: Text(ingredient.name),
      onTap: () {
        histories.add(scaffold.currentState.searchBar.currentState.text);
        Navigator.of(context).pop<IngredientModel>(ingredient);
      },
    );
  }

  Widget _emptyBuilder(BuildContext context, String text) {
    return CardTile(
      title: Text('新增成份「$text」'),
      onTap: () {
        final stock = context.read<StockModel>();
        final ingredient = IngredientModel(name: text);
        stock.addIngredient(ingredient);
        Navigator.of(context).pop<IngredientModel>(ingredient);
      },
    );
  }

  Widget _initialBuilder(BuildContext context) {
    final searchHistory = histories.get(
      () => scaffold.currentState.updateView(),
    );
    if (searchHistory == null) return CircularProgressIndicator();

    return Column(
      children: [
        Text('搜尋紀錄', style: Theme.of(context).textTheme.caption),
        Expanded(
          child: ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              return CardTile(
                title: Text(searchHistory.elementAt(index)),
                onTap: () {
                  scaffold.currentState
                      .setSearchKeyword(searchHistory.elementAt(index));
                },
              );
            },
            itemCount: searchHistory.length,
          ),
        ),
      ],
    );
  }
}
