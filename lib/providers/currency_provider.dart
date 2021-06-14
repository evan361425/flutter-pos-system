import 'package:flutter/material.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/services/cache.dart';

class CurrencyProvider extends ChangeNotifier {
  static late CurrencyProvider instance;

  static const defaultCurrency = '新台幣';

  static const currencyCandidates = {
    '新台幣': [1, 5, 10, 50, 100, 500, 1000],
    'USD': [0.01, 0.05, 0.1, 0.25, 0.5, 1, 5, 10, 20, 50, 100],
  };

  late String _currency;

  /// Current available unit of money
  late List<num> unitList;

  /// Is this currency all int?
  late bool isInt;

  /// Index of integer in [unitList]
  late int intIndex;

  CurrencyProvider() {
    instance = this;
  }

  String get currency => _currency;

  /// Ceiling [value] to currency least value
  ///
  /// TODO: make double ceiling to float point
  ///
  /// ```dart
  /// // types = [5, 10 ,50];
  /// ceil(3) == 5
  /// ceil(6) == 10
  /// ceil(11) == 15
  /// ceil(25) == 30
  /// ceil(30) == 50
  /// ceil(60) == 100
  /// ```
  num? ceil(num? value) {
    if (value == null) return null;

    if (value < 0) return 0;

    // if it is double ceil to int first
    if (value != value.ceil()) return value.ceil();

    final next = unitList.indexWhere((e) => e > value);
    if (next == 0 || next == 1) return unitList[next];

    final useUnits = unitList.sublist(1, next == -1 ? null : next + 1);
    for (var unit in useUnits) {
      if (value % unit != 0) return (value / unit).ceil() * unit;
    }

    return value;
  }

  void initialize() {
    final currency = Cache.instance.get<String>(Caches.currency_code);
    if (!_setCurrency(currency)) {
      _setCurrency(defaultCurrency);
    }
  }

  String numToString(num value) {
    return isInt ? value.round().toString() : value.toString();
  }

  Future<void> setCurrency(String value) async {
    info(value, 'setting.currency');
    await Cache.instance.set<String>(Caches.currency_code, value);

    if (value != _currency && _setCurrency(value)) {
      notifyListeners();
    }
  }

  bool _setCurrency(String? value) {
    if (value == null) return false;

    if (currencyCandidates[value] == null) return false;

    unitList = currencyCandidates[value]!;

    // index when money start using int
    intIndex = 0;
    for (var money in unitList) {
      if (money.toInt() == money) break;
      intIndex++;
    }

    isInt = intIndex == 0;

    _currency = value;

    return true;
  }
}
