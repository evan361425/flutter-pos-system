import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/model.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/repository/quantity_repo.dart';
import 'package:possystem/services/storage.dart';

class QuantityModel extends Model<QuantityObject> {
  // quantity name: less, more, ...
  String name;

  // between 0 ~ 1
  num defaultProportion;

  QuantityModel({
    String? id,
    required this.name,
    num? defaultProportion,
  })  : defaultProportion = defaultProportion ?? 1,
        super(id);

  factory QuantityModel.fromObject(QuantityObject object) => QuantityModel(
        id: object.id,
        name: object.name!,
        defaultProportion: object.defaultProportion!,
      );

  @override
  String get code => 'stock.quantity';

  @override
  Stores get storageStore => Stores.quantities;

  int getSimilarity(String searchText) => Util.similarity(name, searchText);

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
