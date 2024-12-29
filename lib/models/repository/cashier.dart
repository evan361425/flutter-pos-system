import 'dart:math';

import 'package:flutter/material.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/objects/cashier_object.dart';
import 'package:possystem/services/storage.dart';
import 'package:possystem/settings/currency_setting.dart';

class Cashier extends ChangeNotifier {
  static const _favoriteKey = 'favorites';

  static const _currentKey = 'current';

  static const _defaultKey = 'default';

  static late Cashier instance;

  /// Cashier current status
  final List<CashierUnitObject> _current = [];

  /// Cashier default status
  final List<CashierUnitObject> _default = [];

  /// Changer favorite
  final List<CashierChangeBatchObject> _favorites = [];

  /// Cashier current using currency name
  String _recordName = '';

  Cashier() {
    CurrencySetting.instance.addListener(reset);
    instance = this;
  }

  num get currentTotal => _current.fold(0, (value, e) => value + e.total);

  Iterable<CashierUnitObject> get currentUnits sync* {
    for (var item in _current) {
      yield item;
    }
  }

  bool get defaultNotSet => _default.isEmpty;

  num get defaultTotal => _default.fold(0, (value, e) => value + e.total);

  bool get favoriteIsEmpty => _favorites.isEmpty;

  /// Cashier current using currency units length
  int get unitLength => _current.length;

  Future<void> addFavorite(CashierChangeBatchObject item) {
    _favorites.add(item);

    return _updateFavoriteStorage();
  }

  Future<bool> applyFavorite(CashierChangeBatchObject item) async {
    final sourceIndex = indexOf(item.source.unit!);
    if (!validate(sourceIndex, item.source.count!)) {
      return false;
    }

    await update(
        {sourceIndex: -item.source.count!, for (var target in item.targets) indexOf(target.unit!): target.count!});

    return true;
  }

  /// Get current unit from [index]
  CashierUnitObject at(int index) => _current[index];

  /// Get default unit from [index]
  CashierUnitObject? defaultAt(int index) => index < _default.length ? _default[index] : null;

  Future<void> deleteFavorite(int index) async {
    try {
      _favorites.removeAt(index);

      await _updateFavoriteStorage();
    } catch (e, stack) {
      Log.err(e, 'cashier_favorite_remove', stack);
    }
  }

  @override
  void dispose() {
    CurrencySetting.instance.removeListener(reset);
    super.dispose();
  }

  Iterable<FavoriteItem> favoriteItems() sync* {
    var index = 0;
    for (final item in _favorites) {
      yield FavoriteItem(item: item, index: index++);
    }
  }

  /// Find Possible change from [count] and [unit]
  ///
  /// If [count] is equal 1, change smaller unit
  /// else change larger unit
  ///
  /// ```dart
  /// final units = [10, 100, 500]
  /// change(1, 100); // [10-10];
  /// change(1, 10); // null;
  /// change(6, 100); // [1-500];
  /// change(4, 100); // [40-10];
  /// change(9, 10); // null;
  /// ```
  CashierChangeEntryObject? findPossibleChange(int count, num unit) {
    final index = indexOf(unit);
    if (index == -1 || count < 1) {
      return null;
    }

    final total = count * unit;

    if (count == 1) {
      if (index > 0) {
        final unit = at(index - 1).unit;

        return CashierChangeEntryObject(
          unit: unit,
          count: (total / unit).floor(),
        );
      }
    } else {
      for (var i = unitLength - 1; i > index; i--) {
        final iUnit = at(i).unit;

        // if not enough to change this unit
        if (total >= iUnit && iUnit != unit) {
          return CashierChangeEntryObject(
            unit: iUnit,
            count: (total / iUnit).floor(),
          );
        }
      }

      if (index > 0) {
        final unit = at(index - 1).unit;

        return CashierChangeEntryObject(
          unit: unit,
          count: (total / unit).floor(),
        );
      }
    }

    return null;
  }

  /// Current and default difference
  Iterable<CashierDiffItem> getDifference() sync* {
    final iterators = [
      _current,
      _default,
    ].map((e) => e.iterator).toList(growable: false);

    while (iterators.every((e) => e.moveNext())) {
      yield CashierDiffItem(iterators[0].current, iterators[1].current);
    }
  }

  /// Get index of specific [unit]
  int indexOf(num unit) {
    return _current.indexWhere((element) => element.unit == unit);
  }

  /// Set the [count] of specific [unit] in cashier
  Future<void> setUnitCount(num unit, int count) {
    final index = indexOf(unit);
    final diff = count - _current[index].count;
    return update({index: diff});
  }

  /// Customer [given] money for the [price] and update the cashier
  ///
  /// For example:
  /// given 100 for 65, then the cashier will
  /// have add 1 100-dollar bill but minus 3 10-dollar and 1 5-dollar bill
  Future<CashierUpdateStatus> paid(num given, num price) async {
    final amounts = <int, int>{};

    smallChange(amounts, given, add: true);
    final status = smallChange(amounts, given - price, add: false);

    await update(amounts);

    return status;
  }

  CashierUpdateStatus smallChange(
    Map<int, int> amounts,
    num price, {
    bool add = true,
  }) {
    if (price == 0) return CashierUpdateStatus.ok;

    var index = unitLength - 1;
    var status = CashierUpdateStatus.ok;

    for (var item in _current.reversed) {
      if (item.unit <= price) {
        final willAdd = amounts[index] ?? 0;
        // 35 dollar should use 3 of 10 dollar
        final shouldUse = (price / item.unit).floor();
        // should use smaller than cashier have
        final count = add ? shouldUse : min(shouldUse, item.count + willAdd);
        if (count != shouldUse) {
          status = CashierUpdateStatus.usingSmall;
        }

        amounts[index] = willAdd + (add ? count : -count);
        price -= item.unit * count;

        if (price == 0) return status;
      }
      index--;
    }

    return CashierUpdateStatus.notEnough;
  }

  /// When [CurrencySetting] changed, it must be fired
  Future<void> reset() async {
    _recordName = CurrencySetting.instance.recordName;
    final record = await Storage.instance.get(Stores.cashier, _recordName);

    await setCurrent(record[_currentKey]);
    await setFavorite(record[_favoriteKey]);

    if (record[_defaultKey] != null) {
      await setDefault(record[_defaultKey] as Iterable);
    }
  }

  Future<void> setCurrent(Object? record) async {
    try {
      // if null, set to empty units
      if (record == null) {
        throw TypeError();
      }

      _current
        ..clear()
        ..addAll([for (var unit in record as Iterable) CashierUnitObject.fromMap(unit.cast<String, num>())]);
    } catch (e, stack) {
      if (e is! TypeError) {
        Log.err(e, 'cashier_fetch_unit', stack);
      }
      _current
        ..clear()
        ..addAll([for (var unit in CurrencySetting.instance.unitList) CashierUnitObject(unit: unit, count: 0)]);

      // reset to empty
      await _registerStorage();
    }
  }

  Future<void> setCurrentByUnit(num unit, int count) {
    final index = indexOf(unit);
    final diff = count - _current[index].count;
    return update({index: diff});
  }

  /// Set default data
  ///
  /// If [record] is null, it will use current currency
  Future<void> setDefault([Iterable? record]) async {
    if (record == null) {
      final old = defaultTotal;
      _default
        ..clear()
        ..addAll([for (final item in _current) CashierUnitObject(unit: item.unit, count: item.count)]);
      Log.ger('cashier_reset', {'before': old, 'current': defaultTotal});

      notifyListeners();
      return _updateDefaultStorage();
    }
    try {
      _default
        ..clear()
        ..addAll([for (var item in record) CashierUnitObject.fromMap(item.cast<String, num>())]);
    } catch (e, stack) {
      Log.err(e, 'cashier_fetch_default', stack);
    }
    notifyListeners();
  }

  Future<void> setFavorite(Object? record) async {
    try {
      _favorites
        ..clear()
        ..addAll([for (var map in (record ?? []) as Iterable) CashierChangeBatchObject.fromMap(map)]);
    } catch (e, stack) {
      Log.err(e, 'cashier_fetch_favorite', stack);
    }
  }

  Future<void> surplus() async {
    final length = min(_current.length, _default.length);
    for (var i = 0; i < length; i++) {
      _current[i].count = _default[i].count;
    }

    await _updateCurrentStorage();
  }

  /// Update cashier by [deltas]
  ///
  /// [deltas] key is index of units
  Future<void> update(Map<int, int> deltas) async {
    var isUpdated = false;
    deltas.forEach((index, value) {
      _current[index].count += value;
      if (_current[index].count < 0) {
        _current[index].count = 0;
      }
      isUpdated = isUpdated || value != 0;
    });

    if (isUpdated) {
      await _updateCurrentStorage();
    }
  }

  /// Check specific unit by [index] has valid [count] to minus
  bool validate(int index, int count) {
    return _current[index].count >= count;
  }

  Future<void> _registerStorage() {
    return Storage.instance.add(Stores.cashier, _recordName, {
      _currentKey: _current.map((e) => e.toMap()).toList(),
      _defaultKey: [],
      _favoriteKey: [],
    });
  }

  Future<void> _updateCurrentStorage() async {
    await Storage.instance.set(Stores.cashier, {
      '$_recordName.$_currentKey': _current.map((e) => e.toMap()).toList(),
    });

    notifyListeners();
  }

  Future<void> _updateDefaultStorage() {
    return Storage.instance.set(Stores.cashier, {
      '$_recordName.$_defaultKey': _default.map((e) => e.toMap()).toList(),
    });
  }

  Future<void> _updateFavoriteStorage() async {
    await Storage.instance.set(Stores.cashier, {
      '$_recordName.$_favoriteKey': _favorites.map((e) => e.toMap()).toList(),
    });

    notifyListeners();
  }
}

class CashierDiffItem {
  final CashierUnitObject currentData;

  final CashierUnitObject defaultData;

  const CashierDiffItem(this.currentData, this.defaultData);

  int get currentCount => currentData.count;
  int get defaultCount => defaultData.count;
  int get diffCount => currentData.count - defaultData.count;
  num get unit => currentData.unit;
}

/// When the cashier is updating the money will return this
enum CashierUpdateStatus {
  /// When the cashier does not have enough money to change
  notEnough,

  /// When the cashier is using smaller units to change
  ///
  /// For example, change 35 with 2 10-dollar bills and 3 5-dollar bills
  ///
  /// If the cashier does not have enough bills to change,
  /// it will return [CashierUpdateStatus.usingSmall]
  usingSmall,

  /// When the cashier has enough money to change
  ok
}
