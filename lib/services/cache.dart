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
    } else {
      throw Error();
    }
  }

  bool neededTip(String key, int version) {
    if (version == 0) return false;

    final result = service.getInt('_tip.v2.$key') ?? 0;

    return result != version;
  }

  Future<bool> tipRead(String key, int version) {
    return service.setInt('_tip.v2.$key', version);
  }
}

enum Caches {
  dark_mode,
  language_code,
  currency_code,
  outlook_order,
  feature_awake_provider,
}
