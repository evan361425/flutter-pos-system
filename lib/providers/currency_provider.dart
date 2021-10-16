import 'package:flutter/material.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/services/cache.dart';

const _CurrencyNames = <CurrencyTypes, String>{
  CurrencyTypes.TWD: '新台幣',
  CurrencyTypes.USD: 'USD',
};

class CurrencyProvider extends ChangeNotifier {
  static late CurrencyProvider instance;

  static const defaultCurrency = CurrencyTypes.TWD;

  static const currencyCandidates = {
    CurrencyTypes.TWD: [1, 5, 10, 50, 100, 500, 1000],
    CurrencyTypes.USD: [0.01, 0.05, 0.1, 0.25, 0.5, 1, 5, 10, 20, 50, 100],
  };

  CurrencyTypes? _currency;

  /// Current available unit of money
  late List<num> unitList;

  /// Is this currency all int?
  late bool isInt;

  /// Index of integer in [unitList]
  late int intIndex;

  CurrencyProvider() {
    instance = this;
  }

  String get currency => _CurrencyNames[_currency ?? defaultCurrency]!;

  /// Ceiling [value] to currency least value
  ///
  /// 1~4 => 5
  /// 5~9 => 10
  /// 10 => 50
  /// 11~14 => 15
  /// 15~19 => 20
  /// 50 => 100
  /// 110 => 150
  num ceil(num value) {
    assert(value >= 0);

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
    if (_currency != null) return;

    final currency = Cache.instance.get<String>(Caches.currency_code);
    final index = currency == null
        ? -1
        : _CurrencyNames.values.toList().indexOf(currency);

    _setCurrency(index == -1 ? defaultCurrency : CurrencyTypes.values[index]);
  }

  String numToString(num value) {
    return isInt ? value.round().toString() : value.toString();
  }

  Future<void> setCurrency(CurrencyTypes value) async {
    final name = _CurrencyNames[value]!;
    info(name, 'setting.currency');
    await Cache.instance.set<String>(Caches.currency_code, name);

    if (value != _currency) {
      _setCurrency(value);
      notifyListeners();
    }
  }

  void _setCurrency(CurrencyTypes value) {
    unitList = currencyCandidates[value]!;

    // index when money start using int
    intIndex = 0;
    for (var money in unitList) {
      if (money.toInt() == money) break;
      intIndex++;
    }

    isInt = intIndex == 0;

    _currency = value;
  }

  /// Alias of [instance.numToString(value)]
  static String n2s(num value) => instance.numToString(value);
}

enum CurrencyTypes { TWD, USD }
