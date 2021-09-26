import 'package:shared_preferences/shared_preferences.dart';

class Cache {
  static Cache instance = Cache();

  late SharedPreferences service;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    service = await SharedPreferences.getInstance();

    final version = service.getInt('version');
    if (version == null) {
      await service.setInt('version', 1);
    }
  }

  T? get<T>(Caches cache) => getRaw<T>(cache.toString());

  Future<bool> set<T>(Caches cache, T value) => setRaw<T>(
        cache.toString(),
        value,
      );

  T? getRaw<T>(String name) {
    if (T == bool) {
      return service.getBool(name) as T?;
    } else if (T == String) {
      return service.getString(name) as T?;
    } else if (T == int) {
      return service.getInt(name) as T?;
    } else if (T == double) {
      return service.getDouble(name) as T?;
    } else {
      throw ArgumentError();
    }
  }

  Future<bool> setRaw<T>(String name, T value) {
    if (T == bool) {
      return service.setBool(name, value as bool);
    } else if (T == String) {
      return service.setString(name, value as String);
    } else if (T == int) {
      return service.setInt(name, value as int);
    } else if (T == double) {
      return service.setDouble(name, value as double);
    } else {
      throw ArgumentError();
    }
  }
}

enum Caches {
  dark_mode,
  language_code,
  currency_code,
  outlook_order,
  feature_awake_provider,
}
