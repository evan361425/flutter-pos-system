import 'package:flutter/material.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/repository.dart';
import 'package:possystem/models/stock/replenishment.dart';
import 'package:possystem/services/storage.dart';

class Replenisher extends ChangeNotifier
    with
        Repository<Replenishment>,
        NotifyRepository<Replenishment>,
        InitilizableRepository {
  static late Replenisher instance;

  @override
  final String repositoryName = 'Replenisher';

  @override
  final Stores storageStore = Stores.replenisher;

  Replenisher() {
    initialize();

    Replenisher.instance = this;
  }

  @override
  Replenishment buildModel(String id, Map<String, Object?> value) {
    return Replenishment.fromObject(
      ReplenishmentObject.build({
        'id': id,
        ...value,
      }),
    );
  }
}
