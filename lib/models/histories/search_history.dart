import 'dart:collection';

import 'package:possystem/services/database.dart';

class SearchHistory {
  SearchHistory(SearchHistoryTypes type)
      : type = _SearchHistoryTypeString[type];

  final String type;

  static Map<String, Queue<String>> data;

  Queue<String> get(void Function() cb) {
    if (SearchHistory.data == null) {
      Database.instance.get(Collections.search_history).then((snapshot) {
        final Map<String, List<String>> data = snapshot.data();
        SearchHistory.data = data == null
            ? {}
            : data.map<String, Queue<String>>(
                (key, value) => MapEntry(key, Queue.of(value)),
              );
        cb();
      });

      return Queue();
    }

    return SearchHistory.data[type] ?? Queue();
  }

  void add(String history) {
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

    Database.instance.update(
      Collections.search_history,
      {type: SearchHistory.data[type].toList()},
    );
  }
}

enum SearchHistoryTypes {
  ingredient,
  quantity,
}

final _SearchHistoryTypeString = const <SearchHistoryTypes, String>{
  SearchHistoryTypes.ingredient: 'ingredient',
  SearchHistoryTypes.quantity: 'quantity',
};
