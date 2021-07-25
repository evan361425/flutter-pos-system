import 'package:flutter/material.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/repository.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/services/storage.dart';

class Quantities extends ChangeNotifier
    with
        Repository<Quantity>,
        NotifyRepository<Quantity>,
        InitilizableRepository,
        SearchableRepository {
  static late Quantities instance;

  Quantities() {
    initialize();

    Quantities.instance = this;
  }

  @override
  String get itemCode => 'quantities.quantity';

  @override
  Stores get storageStore => Stores.quantities;

  @override
  Quantity buildModel(String id, Map<String, Object?> value) {
    return Quantity.fromObject(
      QuantityObject.build({
        'id': id,
        ...value,
      }),
    );
  }
}
