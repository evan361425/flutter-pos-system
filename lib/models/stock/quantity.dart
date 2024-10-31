import 'package:possystem/models/model.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/services/storage.dart';

class Quantity extends Model<QuantityObject> with ModelStorage<QuantityObject>, ModelSearchable<QuantityObject> {
  /// between 0 ~ 1
  num defaultProportion;

  @override
  final Stores storageStore = Stores.quantities;

  Quantity({
    super.id,
    super.status = ModelStatus.normal,
    super.name = 'quantity',
    this.defaultProportion = 1,
  });

  factory Quantity.fromObject(QuantityObject object) => Quantity(
        id: object.id,
        name: object.name!,
        defaultProportion: object.defaultProportion!,
      );

  factory Quantity.fromRow(Quantity? ori, List<String> row) {
    final p = row.length > 1 ? num.tryParse(row[1]) ?? 1 : 1;
    final status =
        ori == null ? ModelStatus.staged : (p == ori.defaultProportion ? ModelStatus.normal : ModelStatus.updated);

    return Quantity(
      id: ori?.id,
      name: row[0],
      defaultProportion: p,
      status: status,
    );
  }

  @override
  Quantities get repository => Quantities.instance;

  @override
  QuantityObject toObject() => QuantityObject(
        id: id,
        name: name,
        defaultProportion: defaultProportion,
      );
}
