enum Collections {
  menu,
  ingredient,
  ingredient_sets,
}

abstract class Database<T> {
  static Database service;

  final Map<Collections, String> CollectionName = {
    Collections.menu: 'menu',
    Collections.ingredient: 'ingredient',
    Collections.ingredient_sets: 'ingredient_sets',
  };

  Future<T> get(Collections collection);
  Future<T> set(Collections collection, Map<String, dynamic> data);
  Future<void> update(Collections collection, Map<String, dynamic> data);
}
