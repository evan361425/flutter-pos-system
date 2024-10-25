import 'package:flutter/foundation.dart';
import 'package:possystem/models/model.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/services/storage.dart';

class Replenishment extends Model<ReplenishmentObject> with ModelStorage<ReplenishmentObject> {
  /// ingredient id => add number
  final Map<String, num> data;

  @override
  final Stores storageStore = Stores.replenisher;

  Replenishment({
    super.id,
    super.status = ModelStatus.normal,
    super.name = 'replenishment',
    Map<String, num>? data,
  }) : data = data ?? {};

  factory Replenishment.fromObject(ReplenishmentObject object) => Replenishment(
        id: object.id,
        name: object.name,
        data: object.data,
      );

  factory Replenishment.fromRow(
    Replenishment? ori,
    List<String> row,
    Map<String, num> data,
  ) {
    final status = ori == null
        ? ModelStatus.staged
        : (mapEquals<String, num>(data, ori.data) ? ModelStatus.normal : ModelStatus.updated);

    return Replenishment(
      id: ori?.id,
      name: row[0],
      status: status,
      data: data,
    );
  }

  @override
  Replenisher get repository => Replenisher.instance;

  Map<Ingredient, num> get ingredientData => {
        for (final entry in data.entries.where(
          (entry) => Stock.instance.hasItem(entry.key),
        ))
          Stock.instance.getItem(entry.key)!: entry.value,
      };

  Future<void> apply() => Stock.instance.applyAmounts(data);

  num? getNumOfId(String id) => data[id];

  @override
  ReplenishmentObject toObject() => ReplenishmentObject(
        id: id,
        name: name,
        data: data,
      );
}
