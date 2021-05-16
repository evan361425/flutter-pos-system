import 'package:possystem/services/database.dart';

final _SearchHistoryTypeString = const <SearchHistoryTypes, String>{
  SearchHistoryTypes.ingredient: 'ingredient',
  SearchHistoryTypes.quantity: 'quantity',
};

class SearchHistory {
  final String type;

  SearchHistory(SearchHistoryTypes type)
      : type = _SearchHistoryTypeString[type];

  Future<void> add(String history) {
    return Database.instance.push(
      Tables.search_history,
      {
        'type': type,
        'value': history,
      },
    );
  }

  Future<Iterable<String>> get() async {
    final list = await Database.instance.get(
      Tables.search_history,
      where: 'type = ?',
      whereArgs: [type],
    );

    return list.map<String>((e) => e['value']);
  }
}

enum SearchHistoryTypes {
  ingredient,
  quantity,
}
