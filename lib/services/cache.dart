import 'package:shared_preferences/shared_preferences.dart';

class Cache {
  static Cache instance = Cache();

  late SharedPreferences service;

  bool _initialized = false;

  T? get<T>(String name) {
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

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    service = await SharedPreferences.getInstance();

    final version = service.getInt('version');
    if (version == null) {
      await service.setInt('version', 1);
    }
  }

  Future<void> reset() {
    return service.clear();
  }

  Future<bool> set<T>(String key, T value) {
    if (T == bool) {
      return service.setBool(key, value as bool);
    } else if (T == String) {
      return service.setString(key, value as String);
    } else if (T == int) {
      return service.setInt(key, value as int);
    } else if (T == double) {
      return service.setDouble(key, value as double);
    } else {
      throw ArgumentError();
    }
  }
}
