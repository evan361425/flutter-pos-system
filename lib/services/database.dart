enum Collections {
  menu,
  ingredient,
  ingredient_sets,
  search_history,
}

abstract class Database<T> {
  static Database service;

  final Map<Collections, String> CollectionName = {
    Collections.menu: 'menu',
    Collections.ingredient: 'ingredient',
    Collections.ingredient_sets: 'ingredient_sets',
    Collections.search_history: 'search_history',
  };

  Future<T> get(Collections collection);
  Future<T> set(Collections collection, Map<String, dynamic> data);
  Future<void> update(Collections collection, Map<String, dynamic> data);
}
