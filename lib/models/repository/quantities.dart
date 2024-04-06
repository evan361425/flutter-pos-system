import 'package:flutter/material.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/repository.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/services/storage.dart';

class Quantities extends ChangeNotifier
    with Repository<Quantity>, RepositoryStorage<Quantity>, RepositorySearchable<Quantity> {
  static late Quantities instance;

  @override
  final Stores storageStore = Stores.quantities;

  Quantities() {
    instance = this;
  }

  @override
  Quantity buildItem(String id, Map<String, Object?> value) {
    return Quantity.fromObject(
      QuantityObject.build({
        'id': id,
        ...value,
      }),
    );
  }

  @override
  Future<void> commitStaged({bool save = true, bool reset = true}) {
    // Avoid reset since it will effect Menu
    return super.commitStaged(save: save, reset: false);
  }
}
