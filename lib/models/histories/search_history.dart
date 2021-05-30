import 'package:possystem/services/cache.dart';

final _ToCaches = const <SearchHistoryTypes, Caches>{
  SearchHistoryTypes.ingredient: Caches.search_ingredient,
  SearchHistoryTypes.quantity: Caches.search_quantity,
};

class SearchHistory {
  final Caches type;
  List<String>? histories;

  SearchHistory(SearchHistoryTypes type) : type = _ToCaches[type]!;

  Future<void> add(String history) async {
    // sometimes user enter too fast, need to wait for adding keyword
    if (histories == null) await get();

    histories!.remove(history);
    histories!.insert(0, history);
    if (histories!.length > 8) histories!.removeLast();

    await Cache.instance.set<List>(type, histories!);
  }

  Future<Iterable<String>> get() async {
    if (histories == null) {
      final data = await Cache.instance.get<List>(type) as List<String>?;
      histories = data ?? [];
    }

    return histories!;
  }
}

enum SearchHistoryTypes {
  ingredient,
  quantity,
}
