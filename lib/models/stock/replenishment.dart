import 'package:possystem/models/model.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/services/storage.dart';

class Replenishment extends NotifyModel {
  /// ingredient id => add number
  final Map<String, num> data;

  Replenishment({
    required String name,
    String? id,
    Map<String, num>? data,
  })  : data = data ?? {},
        super(id) {
    this.name = name;
  }

  factory Replenishment.fromObject(ReplenishmentObject object) => Replenishment(
        id: object.id,
        name: object.name,
        data: object.data,
      );

  @override
  String get code => 'stock.batch';

  @override
  Stores get storageStore => Stores.replenisher;

  void apply() => Stock.instance.applyAmounts(data);

  num? getNumOfId(String id) => data[id];

  @override
  void removeFromRepo() {
    Replenisher.instance.removeItem(id);
  }

  @override
  ReplenishmentObject toObject() => ReplenishmentObject(
        id: id,
        name: name,
        data: data,
      );

  @override
  String toString() => name;
}
