import 'package:shared_preferences/shared_preferences.dart';

const _Names = <Caches, String>{
  Caches.currency_code: 'currency_code',
  Caches.dark_mode: 'is_dark_mode',
  Caches.language_code: 'language_code',
  Caches.search_ingredient: 'search_ingredient',
  Caches.search_quantity: 'search_quantity',
};

class Cache {
  static final Cache _instance = Cache._constructor();

  static Cache get instance => _instance;

  final Future<SharedPreferences> _sharedPreference =
      SharedPreferences.getInstance();

  Cache._constructor();

  Future<T?> get<T>(Caches cache) async {
    final sp = await _sharedPreference;
    final name = _Names[cache] ?? cache.toString();

    if (T == bool) {
      return sp.getBool(name) as T?;
    } else if (T == String) {
      return sp.getString(name) as T?;
    } else if (T == int) {
      return sp.getInt(name) as T?;
    } else if (T == double) {
      return sp.getDouble(name) as T?;
    } else if (T == List) {
      return sp.getStringList(name) as T?;
    } else {
      throw Error();
    }
  }

  Future<bool> set<T>(Caches cache, T value) async {
    final sp = await _sharedPreference;
    final name = _Names[cache] ?? cache.toString();

    if (T == bool) {
      return sp.setBool(name, value as bool);
    } else if (T == String) {
      return sp.setString(name, value as String);
    } else if (T == int) {
      return sp.setInt(name, value as int);
    } else if (T == double) {
      return sp.setDouble(name, value as double);
    } else if (T == List) {
      return sp.setStringList(name, value as List<String>);
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
