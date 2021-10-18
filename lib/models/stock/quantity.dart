import 'package:possystem/models/model.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/services/storage.dart';

class Quantity extends NotifyModel<QuantityObject> with SearchableModel {
  /// between 0 ~ 1
  num defaultProportion;

  @override
  final String logCode = 'stock.quantity';

  @override
  final Stores storageStore = Stores.quantities;

  Quantity({
    String? id,
    String name = 'quantity',
    this.defaultProportion = 1,
  }) : super(id) {
    this.name = name;
  }

  factory Quantity.fromObject(QuantityObject object) => Quantity(
        id: object.id,
        name: object.name!,
        defaultProportion: object.defaultProportion!,
      );

  @override
  void removeFromRepo() {
    Quantities.instance
      ..removeItem(prefix)
      ..notifyItem();
  }

  @override
  QuantityObject toObject() => QuantityObject(
        id: id,
        name: name,
        defaultProportion: defaultProportion,
      );
}
