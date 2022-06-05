import 'package:flutter/material.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/services/cache.dart';

abstract class Setting<T> extends ChangeNotifier {
  late T value;

  String get key;

  String get logKey => key.replaceAll('.', '_');

  bool get registryForApp => false;

  Cache get service => Cache.instance;

  void initialize();

  Future<void> update(T data) async {
    if (value == data) return;

    Log.ger('update', 'setting_$logKey', data.toString());
    value = data;

    notifyListeners();

    await updateRemotely(data);
  }

  Future<void> updateRemotely(T data);
}
