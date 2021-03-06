import 'package:flutter/material.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/repository.dart';
import 'package:possystem/models/stock/quantity_model.dart';
import 'package:possystem/services/storage.dart';

class QuantityRepo extends ChangeNotifier
    with
        Repository<QuantityModel>,
        NotifyRepository<QuantityModel>,
        InitilizableRepository,
        SearchableRepository {
  static late QuantityRepo instance;

  QuantityRepo() {
    initialize();

    QuantityRepo.instance = this;
  }

  @override
  String get itemCode => 'quantities.quantity';

  @override
  Stores get storageStore => Stores.quantities;

  @override
  QuantityModel buildModel(String id, Map<String, Object?> value) {
    return QuantityModel.fromObject(
      QuantityObject.build({
        'id': id,
        ...value,
      }),
    );
  }
}
