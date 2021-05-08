import 'package:flutter/material.dart';
import 'package:possystem/components/card_tile.dart';
import 'package:possystem/components/circular_loading.dart';
import 'package:possystem/components/scaffold/search_scaffold.dart';
import 'package:possystem/models/repository/quantity_repo.dart';
import 'package:possystem/models/stock/quantity_model.dart';
import 'package:possystem/models/histories/search_history.dart';

class QuantitySearchScaffold extends StatelessWidget {
  QuantitySearchScaffold({Key key, this.text}) : super(key: key);

  static final String tag = 'menu.poduct.quantity.search';
  final String text;
  final scaffold = GlobalKey<SearchScaffoldState>();
  final histories = SearchHistory(SearchHistoryTypes.quantity);

  @override
  Widget build(BuildContext context) {
    return SearchScaffold<QuantityModel>(
      key: scaffold,
      onChanged: (String text) async =>
          QuantityRepo.instance.sortBySimilarity(text),
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
      onTap: () {
        histories.add(scaffold.currentState.searchBar.currentState.text);
        Navigator.of(context).pop<QuantityModel>(ingredient);
      },
    );
  }

  Widget _emptyBuilder(BuildContext context, String text) {
    return CardTile(
      title: Text('新增成份份量「$text」'),
      onTap: () {
        histories.add(scaffold.currentState.searchBar.currentState.text);
        final quantity = QuantityModel(name: text);
        QuantityRepo.instance.updateQuantity(quantity);
        Navigator.of(context).pop<QuantityModel>(quantity);
      },
    );
  }

  Widget _initialBuilder(BuildContext context) {
    final searchHistory = histories.get(
      () => scaffold.currentState.updateView(),
    );
    if (searchHistory == null) return CircularLoading();

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
