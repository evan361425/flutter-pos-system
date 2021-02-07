enum Collections {
  menu,
}

abstract class Database<T> {
  final Map<Collections, String> CollectionName = {
    Collections.menu: 'menu',
  };

  Future<T> get(Collections collection);
  Future<T> set(Collections collection, Map<String, dynamic> data);
  Future<void> update(Collections collection, Map<String, dynamic> data);
}
