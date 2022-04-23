import 'package:possystem/models/model.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/repository.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/services/storage.dart';

class Quantity extends Model<QuantityObject>
    with ModelStorage<QuantityObject>, ModelSearchable<QuantityObject> {
  /// between 0 ~ 1
  num defaultProportion;

  @override
  final Stores storageStore = Stores.quantities;

  Quantity({
    String? id,
    ModelStatus? status,
    String name = 'quantity',
    this.defaultProportion = 1,
  }) : super(id, status) {
    this.name = name;
  }

  factory Quantity.fromObject(QuantityObject object) => Quantity(
        id: object.id,
        name: object.name!,
        defaultProportion: object.defaultProportion!,
      );

  factory Quantity.fromColumns(Quantity? ori, List<String> columns) {
    final status = ori == null ? ModelStatus.staged : ModelStatus.updated;

    return Quantity(
      id: ori?.id,
      name: columns[0],
      defaultProportion: num.parse(columns[1]),
      status: status,
    );
  }

  @override
  Quantities get repository => Quantities.instance;

  @override
  set repository(Repository repo) {}

  @override
  QuantityObject toObject() => QuantityObject(
        id: id,
        name: name,
        defaultProportion: defaultProportion,
      );
}
