import 'package:flutter/material.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/services/cache.dart';

abstract class Setting<T> extends ChangeNotifier {
  late T value;

  String get key;

  String get logKey => key.replaceAll('.', '_');

  /// Whether the app should be rebuilt when the setting is changed
  ///
  /// e.g. theme, language
  bool get registryForApp => false;

  Cache get service => Cache.instance;

  void initialize();

  Future<void> update(T data) async {
    if (value == data) return;

    Log.ger('user_setting', {'key': logKey, 'value': data.toString()});
    value = data;

    notifyListeners();

    await updateRemotely(data);
    Log.out('finish setting', 'user_setting');
  }

  Future<void> updateRemotely(T data);
}
