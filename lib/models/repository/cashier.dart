import 'package:flutter/material.dart';
import 'package:possystem/models/objects/cashier_object.dart';
import 'package:possystem/services/storage.dart';

class Cashier extends ChangeNotifier {
  static Cashier instance = Cashier();

  final List<CashierUnitObject> _units = [];

  final List<CashierChangeBatchObject> _favorites = [];

  late String _recordName;

  int get favoriteLength => _favorites.length;

  bool get hasFavorites => _favorites.isNotEmpty;

  int get length => _units.length;

  void add(int index, int count) {
    update({index: count});
  }

  Future<void> addFavorite(CashierChangeBatchObject item) async {
    _favorites.add(item);

    await Storage.instance.set(Stores.cashier, {
      '$_recordName.favorites': _favorites.map((e) => e.toMap()).toList(),
    });
  }

  CashierUnitObject at(int index) {
    return _units[index];
  }

  /// Get change from [count] and [unit]
  ///
  /// If [count] is equal 1, change smaller unit
  /// else change larger unit
  ///
  /// ```dart
  /// final units = [10, 100, 500, 1000]
  /// change(10, 100); // [2-500];
  /// change(1, 100); // [10-10];
  /// ```
  List<CashierChangeEntryObject> change(int count, num unit) {
    final index = _units.indexWhere((element) => element.unit == unit);
    if (index == -1) {
      return [];
    }

    if (count == 1) {
      final result = <CashierChangeEntryObject>[];
      for (var i = index - 1; i >= 0; i--) {
        final unitObject = _units[i];
        final unitCount = (unit / unitObject.unit).floor();
        unit -= unitCount * unitObject.unit;

        result.add(CashierChangeEntryObject(
          unit: unitObject.unit,
          count: unitCount,
        ));

        if (unit == 0) {
          break;
        }
      }

      return result;
    } else if (count > 1) {
      final result = <CashierChangeEntryObject>[];
      var total = count * unit;

      for (var i = length - 1; i > index; i--) {
        final unitObject = _units[i];
        // if not enough to change this unit
        if (total < unitObject.unit) {
          continue;
        }

        final unitCount = (total / unitObject.unit).floor();

        result.add(CashierChangeEntryObject(
          unit: unitObject.unit,
          count: unitCount,
        ));

        break;
      }

      return result;
    }

    return [];
  }

  CashierChangeBatchObject favoriteAt(int index) {
    return _favorites[index];
  }

  int indexOf(num unit) {
    return _units.indexWhere((element) => element.unit == unit);
  }

  void minus(int index, int count) {
    update({index: -count});
  }

  /// When currency changed, it must be changed
  Future<void> reset(String name, List<num> units) async {
    _recordName = name;
    final record = await Storage.instance.get(Stores.cashier, name);

    await setUnits(name: name, units: record['units'], defaultUnits: units);
    await setFavorite(name: name, favorites: record['favorites']);
  }

  Future<void> setFavorite({required String name, Object? favorites}) async {
    try {
      _favorites
        ..clear()
        ..addAll([
          for (var map in (favorites ?? []) as Iterable)
            CashierChangeBatchObject.fromMap(map)
        ]);
    } catch (e) {
      print(e);
      _favorites.clear();
    }
  }

  Future<void> setUnits({
    required String name,
    Object? units,
    required List<num> defaultUnits,
  }) async {
    try {
      if (units == null) throw Error();
      _units
        ..clear()
        ..addAll([
          for (var unit in units as Iterable)
            CashierUnitObject.fromMap(unit.cast<String, num>())
        ]);
    } catch (e) {
      print(e);
      _units
        ..clear()
        ..addAll([
          for (var unit in defaultUnits) CashierUnitObject(unit: unit, count: 0)
        ]);

      await Storage.instance.add(Stores.cashier, name, {
        'units': _units.map((e) => e.toMap()).toList(),
      });
    }
  }

  /// Update chashier by [deltas]
  ///
  /// [deltas] key is index of units
  Future<void> update(Map<int, int> deltas) async {
    var isUpdated = false;
    deltas.forEach((index, value) {
      _units[index].count += value;
      if (_units[index].count < 0) {
        _units[index].count = 0;
      }
      isUpdated = isUpdated || value != 0;
    });

    if (isUpdated) {
      await Storage.instance.set(Stores.cashier, {
        '$_recordName.units': _units.map((e) => e.toMap()).toList(),
      });

      notifyListeners();
    }
  }

  /// Check specific unit by [index] has valid [count] to minus
  bool validate(int index, int count) {
    return _units[index].count >= count;
  }
}
