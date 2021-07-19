import 'package:flutter/material.dart';
import 'package:possystem/models/objects/cashier_object.dart';
import 'package:possystem/services/storage.dart';

class Cashier extends ChangeNotifier {
  static Cashier instance = Cashier();

  final List<CashierUnitObject> _units = [];

  final List<CashierChangeBatchObject> favorites = [];

  late String _recordName;

  int get length => _units.length;

  void add(int index, int count) {
    update({index: count});
  }

  CashierUnitObject at(int index) {
    return _units[index];
  }

  int indexOf(num unit) {
    return _units.indexWhere((element) => element.unit == unit);
  }

  Future<void> addFavorite(CashierChangeBatchObject item) async {
    favorites.add(item);

    await Storage.instance.set(Stores.cashier, {
      '$_recordName.favorites': favorites.map((e) => e.toMap()).toList(),
    });
  }

  void minus(int index, int count) {
    update({index: -count});
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

  /// When currency changed, it must be changed
  Future<void> reset(String name, List<num> units) async {
    _recordName = name;
    final record = await Storage.instance.get(Stores.cashier, name);

    if (record.isEmpty || record['units'] == null) {
      _units
        ..clear()
        ..addAll(
            [for (var unit in units) CashierUnitObject(unit: unit, count: 0)]);

      await Storage.instance.add(Stores.cashier, name, {
        'units': _units.map((e) => e.toMap()).toList(),
      });
    } else {
      _units
        ..clear()
        ..addAll([
          for (var map in record['units'] as Iterable)
            CashierUnitObject.fromMap(map.cast<String, num>())
        ]);
      favorites
        ..clear()
        ..addAll([
          for (var map in record['favorites'] as Iterable)
            CashierChangeBatchObject.fromMap(map.cast<String, Map<num, int>>())
        ]);
    }
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
}
