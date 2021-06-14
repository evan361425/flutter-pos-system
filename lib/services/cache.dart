import 'package:shared_preferences/shared_preferences.dart';

const _Names = <Caches, String>{
  Caches.currency_code: 'currency_code',
  Caches.dark_mode: 'is_dark_mode',
  Caches.language_code: 'language_code',
  Caches.search_ingredient: 'search_ingredient',
  Caches.search_quantity: 'search_quantity',
};

class Cache {
  static Cache instance = Cache();

  late final SharedPreferences service;

  Future<void> initialize() async {
    service = await SharedPreferences.getInstance();
  }

  T? get<T>(Caches cache) {
    final name = _Names[cache] ?? cache.toString();

    if (T == bool) {
      return service.getBool(name) as T?;
    } else if (T == String) {
      return service.getString(name) as T?;
    } else if (T == int) {
      return service.getInt(name) as T?;
    } else if (T == double) {
      return service.getDouble(name) as T?;
    } else if (T == List) {
      return service.getStringList(name) as T?;
    } else {
      throw Error();
    }
  }

  Future<bool> set<T>(Caches cache, T value) {
    final name = _Names[cache] ?? cache.toString();

    if (T == bool) {
      return service.setBool(name, value as bool);
    } else if (T == String) {
      return service.setString(name, value as String);
    } else if (T == int) {
      return service.setInt(name, value as int);
    } else if (T == double) {
      return service.setDouble(name, value as double);
    } else if (T == List) {
      return service.setStringList(name, value as List<String>);
    } else {
      throw Error();
    }
  }
}

enum Caches {
  dark_mode,
  language_code,
  currency_code,
  search_ingredient,
  search_quantity,
  // application
  analyze_calendar_format,
}
