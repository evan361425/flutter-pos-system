import 'package:possystem/models/model.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/repository.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/services/storage.dart';

class Replenishment extends Model<ReplenishmentObject>
    with ModelStorage<ReplenishmentObject> {
  /// ingredient id => add number
  final Map<String, num> data;

  @override
  final Stores storageStore = Stores.replenisher;

  Replenishment({
    String? id,
    String name = 'replenishment',
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
  Replenisher get repository => Replenisher.instance;

  @override
  set repository(Repository repo) {}

  Future<void> apply() => Stock.instance.applyAmounts(data);

  num? getNumOfId(String id) => data[id];

  @override
  ReplenishmentObject toObject() => ReplenishmentObject(
        id: id,
        name: name,
        data: data,
      );
}
