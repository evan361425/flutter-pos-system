import 'package:shared_preferences/shared_preferences.dart';

class Cache {
  static Cache instance = Cache();

  late SharedPreferences service;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    service = await SharedPreferences.getInstance();

    final version = service.getInt('version');
    if (version == null) {
      await service.setInt('version', 1);
    }

    _initialized = true;
  }

  T? get<T>(Caches cache) {
    final name = cache.toString();

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
    final name = cache.toString();

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

  bool needTutorial(String key) {
    final isRead = service.getBool('_tutorial.$key');

    if (isRead != null) return false;

    service.setBool('_tutorial.$key', true);
    return true;
  }
}

enum Caches {
  dark_mode,
  language_code,
  currency_code,
  search_ingredient,
  search_quantity,
}
