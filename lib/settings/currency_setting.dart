import 'package:possystem/settings/setting.dart';

class CurrencySetting extends Setting<CurrencyTypes> {
  static late CurrencySetting instance;

  static const defaultCurrency = CurrencyTypes.twd;

  static const supports = {
    CurrencyTypes.twd: [1, 5, 10, 50, 100, 500, 1000],
    CurrencyTypes.usd: [0.01, 0.05, 0.1, 0.25, 0.5, 1, 5, 10, 20, 50, 100],
  };

  /// Current available unit of money
  late List<num> unitList;

  /// Is this currency all int?
  late bool isInt;

  /// Index of integer in [unitList]
  late int intIndex;

  CurrencySetting() {
    instance = this;
  }

  @override
  String get key => 'currency';

  String get recordName => '新台幣';

  /// Ceiling [value] to currency least value
  ///
  /// 1~4 => 5
  /// 5~9 => 10
  /// 10 => 50
  /// 11~14 => 15
  /// 15~19 => 20
  /// 50 => 100
  /// 110 => 150
  num ceil(num data) {
    assert(data >= 0);

    if (data == 0) return 0;

    // if it is double ceil to int first
    if (data != data.ceil()) return data.ceil();

    final next = unitList.indexWhere((e) => e > data);
    if (next == 0 || next == 1) return unitList[next];

    final useUnits = unitList.sublist(1, next == -1 ? null : next + 1);
    for (var unit in useUnits) {
      if (data % unit != 0) {
        return (data / unit).ceil() * unit;
      }
    }

    return data;
  }

  /// Get all possible value to currency maximum
  ///
  /// Ex. 63 => [65, 70, 100, 500, 1000]
  Iterable<num> ceilToMaximum(num minimum) sync* {
    yield minimum;

    var value = minimum;
    var ceiledValue = ceil(value);
    while (ceiledValue != value) {
      yield ceiledValue;
      value = ceiledValue;
      ceiledValue = CurrencySetting.instance.ceil(ceiledValue);
    }
  }

  @override
  void initialize() {
    value = CurrencyTypes.values[service.get<int>(key) ?? 0];
    _setMetadata(value);
  }

  @override
  Future<void> updateRemotely(CurrencyTypes data) {
    return service.set<int>(key, data.index);
  }

  void _setMetadata(CurrencyTypes value) {
    unitList = supports[value]!;

    // index when money start using int
    intIndex = 0;
    for (var money in unitList) {
      if (money.toInt() == money) break;
      intIndex++;
    }

    isInt = intIndex == 0;
  }
}

enum CurrencyTypes {
  twd,
  usd,
}

extension ToCurrency on num {
  /// Parse value to int or double string, decided by [CurrencySetting.isInt]
  String toCurrency() {
    return CurrencySetting.instance.isInt ? round().toString() : toString();
  }

  num toCurrencyNum() {
    return CurrencySetting.instance.isInt ? round() : this;
  }
}
