import 'dart:math';

import 'package:flutter/material.dart';
import 'package:possystem/components/card_tile.dart';
import 'package:possystem/components/scaffold/search_scaffold.dart';
import 'package:possystem/models/repository/quantity_index_model.dart';
import 'package:possystem/models/stock/quantity_model.dart';
import 'package:possystem/models/search_history_model.dart';
import 'package:provider/provider.dart';

class QuantitySearchScaffold extends StatelessWidget {
  QuantitySearchScaffold({Key key, this.text}) : super(key: key);

  static final String tag = 'menu.poduct.quantity.search';
  final String text;
  final scaffold = GlobalKey<SearchScaffoldState>();
  final histories = SearchHistoryModel(SearchHistoryTypes.quantity);

  @override
  Widget build(BuildContext context) {
    final quantitiesIndex = context.watch<QuantityIndexModel>();
    var sortedIngredients = <QuantityModel>[];
    return SearchScaffold<QuantityModel>(
      key: scaffold,
      onChanged: (String text) async {
        if (text.isEmpty) {
          sortedIngredients = [];
          return [];
        }

        sortedIngredients = quantitiesIndex.quantities.values
            .map<QuantityModel>((e) => e..setSimilarity(text))
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
      heroTag: QuantitySearchScaffold.tag,
      text: text,
      hintText: '成份份量名稱，例如：少量',
      textCapitalization: TextCapitalization.words,
    );
  }

  Widget _itemBuilder(BuildContext context, dynamic ingredient) {
    return CardTile(
      title: Text(ingredient.name),
      onTap: () => Navigator.of(context).pop<QuantityModel>(ingredient),
    );
  }

  Widget _emptyBuilder(BuildContext context, String text) {
    return CardTile(
      title: Text('新增成份份量「$text」'),
      onTap: () {
        histories.add(scaffold.currentState.searchBar.currentState.text);
        final quantities = context.read<QuantityIndexModel>();
        final quantity = quantities.addQuantity(text);
        Navigator.of(context).pop<QuantityModel>(quantity);
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
                  scaffold.currentState.setSearchKeyword(
                    searchHistory.elementAt(index),
                  );
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
