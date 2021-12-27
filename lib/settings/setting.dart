import 'package:flutter/material.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/services/cache.dart';

abstract class Setting<T> extends ChangeNotifier {
  late T value;

  String get key;

  bool get registyForApp => false;

  Cache get service => Cache.instance;

  void initialize();

  Future<void> update(T data) async {
    if (value == data) return;

    info(data.toString(), 'setting.$key');

    value = data;

    notifyListeners();

    await updateRemotely(data);
  }

  Future<void> updateRemotely(T data);
}
