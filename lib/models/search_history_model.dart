import 'dart:collection';

import 'package:possystem/services/database.dart';

class SearchHistoryModel {
  SearchHistoryModel(SearchHistoryTypes type)
      : type = _SearchHistoryTypeString[type];

  final String type;

  static Map<String, Queue<String>> data;

  Queue<String> get(void Function() cb) {
    if (SearchHistoryModel.data == null) {
      Database.service.get(Collections.search_history).then((snapshot) {
        final Map<String, List<String>> data = snapshot.data();
        SearchHistoryModel.data = data == null
            ? {}
            : data.map<String, Queue<String>>(
                (key, value) => MapEntry(key, Queue.of(value)),
              );
        cb();
      });

      return Queue();
    }

    return SearchHistoryModel.data[type] ?? Queue();
  }

  void add(String history) {
    print('$type history add: $history');
    if (SearchHistoryModel.data[type] == null) {
      SearchHistoryModel.data[type] = Queue.of([history]);
    } else {
      SearchHistoryModel.data[type].addFirst(history);
    }

    if (SearchHistoryModel.data[type].length > 8) {
      SearchHistoryModel.data[type].removeLast();
    }

    Database.service.update(
      Collections.search_history,
      {type: SearchHistoryModel.data[type].toList()},
    );
  }
}

enum SearchHistoryTypes {
  ingredient,
  ingredient_set,
}

final _SearchHistoryTypeString = const <SearchHistoryTypes, String>{
  SearchHistoryTypes.ingredient: 'ingredient',
  SearchHistoryTypes.ingredient_set: 'ingredient_set',
};
