import 'dart:collection';

import 'package:possystem/services/database.dart';

final _SearchHistoryTypeString = const <SearchHistoryTypes, String>{
  SearchHistoryTypes.ingredient: 'ingredient',
  SearchHistoryTypes.quantity: 'quantity',
};

class SearchHistory {
  static Map<String, Queue<String>> data;

  final String type;

  SearchHistory(SearchHistoryTypes type)
      : type = _SearchHistoryTypeString[type];

  Future<void> add(String history) {
    print('$type history add: $history');
    if (SearchHistory.data[type] == null) {
      SearchHistory.data[type] = Queue.of([history]);
    } else {
      SearchHistory.data[type].remove(history);
      SearchHistory.data[type].addFirst(history);
    }

    if (SearchHistory.data[type].length > 8) {
      SearchHistory.data[type].removeLast();
    }

    return Database.instance.update(
      Collections.search_history,
      {type: SearchHistory.data[type].toList()},
    );
  }

  Queue<String> get(void Function() cb) {
    if (SearchHistory.data == null) {
      Database.instance.get(Collections.search_history).then((snapshot) {
        final data = snapshot.data();
        SearchHistory.data = data == null
            ? {}
            : data.map<String, Queue<String>>(
                (key, value) => MapEntry(key, Queue.of(value)),
              );
        cb();
      });

      return null;
    }

    return SearchHistory.data[type] ?? Queue();
  }
}

enum SearchHistoryTypes {
  ingredient,
  quantity,
}
