enum Collections {
  menu,
  ingredient,
  quantities,
  search_history,
  order_history,
  order_stash,
  stock_batch,
}

abstract class Database<T> {
  static Database instance;

  final Map<Collections, String> CollectionName = {
    Collections.menu: 'menu',
    Collections.ingredient: 'ingredient',
    Collections.quantities: 'quantities',
    Collections.search_history: 'search_history',
    Collections.order_history: 'order_history',
    Collections.order_stash: 'order_stash',
    Collections.stock_batch: 'stock_batch',
  };

  Future<T> get(Collections collection);
  Future<T> set(Collections collection, Map<String, dynamic> data);
  Future<T> pop(Collections collection, [remove = true]);
  Future<void> push(Collections collection, Map<String, dynamic> data);
  Future<void> update(Collections collection, Map<String, dynamic> data);
}
