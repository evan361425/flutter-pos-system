import 'package:possystem/services/cache.dart';

final _ToCaches = const <SearchHistoryTypes, Caches>{
  SearchHistoryTypes.ingredient: Caches.search_ingredient,
  SearchHistoryTypes.quantity: Caches.search_quantity,
};

class SearchHistory {
  final Caches type;
  List<String> histories;

  SearchHistory(SearchHistoryTypes type) : type = _ToCaches[type];

  Future<void> add(String history) {
    histories.remove(history);
    histories.insert(0, history);
    if (histories.length > 8) histories.removeLast();

    return Cache.instance.set<List>(type, histories);
  }

  Future<Iterable<String>> get() async {
    histories ??= await Cache.instance.get<List>(type) ?? [];
    return histories;
  }
}

enum SearchHistoryTypes {
  ingredient,
  quantity,
}
