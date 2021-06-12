import 'package:possystem/models/model.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/repository/quantity_repo.dart';
import 'package:possystem/services/storage.dart';

class QuantityModel extends NotifyModel<QuantityObject> with SearchableModel {
  /// between 0 ~ 1
  num defaultProportion;

  QuantityModel({
    String? id,
    required String name,
    num? defaultProportion,
  })  : defaultProportion = defaultProportion ?? 1,
        super(id) {
    this.name = name;
  }

  factory QuantityModel.fromObject(QuantityObject object) => QuantityModel(
        id: object.id,
        name: object.name!,
        defaultProportion: object.defaultProportion!,
      );

  @override
  String get code => 'stock.quantity';

  @override
  Stores get storageStore => Stores.quantities;

  @override
  void removeFromRepo() {
    QuantityRepo.instance.removeChild(prefix);
  }

  @override
  QuantityObject toObject() => QuantityObject(
        id: id,
        name: name,
        defaultProportion: defaultProportion,
      );

  @override
  String toString() => name;
}
