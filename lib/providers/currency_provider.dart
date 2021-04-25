import 'package:flutter/material.dart';
import 'package:possystem/caches/shared_preference_cache.dart';

class CurrencyProvider extends ChangeNotifier {
  static const candidates = {
    '新台幣': [1, 5, 10, 50, 100, 500, 1000],
  };

  String _usage;

  List<num> types;

  bool isInt;

  int intIndex;

  CurrencyProvider() {
    _setUsage('新台幣');
  }

  // if value = 24 => 25
  // if value = 27 => 30
  // if value = 30 => 50
  // if value = 100 => 500
  num ceil(num value) {
    if (value == null) return null;

    if (value != value.ceil()) return value.ceil();

    final nextIndex = types.indexWhere((e) => e > value);
    if (nextIndex == 0 || nextIndex == 1) return types[nextIndex];

    final useTypes = types.sublist(1, nextIndex == -1 ? null : nextIndex + 1);
    for (var type in useTypes) {
      if (value % type != 0) return (value / type).ceil() * type;
    }

    return value;
  }

  String get usage {
    SharedPreferenceCache.instance.currency.then((value) => _setUsage(value));

    return _usage;
  }

  set usage(String value) {
    SharedPreferenceCache.instance
        .setCurrency(value)
        .then<void>((_) => _setUsage(value));
  }

  void _setUsage(String value) {
    if (value != null && value != _usage) {
      types = candidates[value];

      // index when money start using int
      intIndex = 0;
      for (var type in types) {
        if (type.toInt() == type) break;
        intIndex++;
      }

      // is this currency all int?
      isInt = intIndex == 0;

      // notify if already created
      if (_usage != null) notifyListeners();

      _usage = value;
    }
  }
}
