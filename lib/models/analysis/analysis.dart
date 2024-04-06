import 'package:flutter/foundation.dart';
import 'package:possystem/models/analysis/chart.dart';
import 'package:possystem/models/analysis/chart_object.dart';
import 'package:possystem/models/repository.dart';
import 'package:possystem/services/storage.dart';

class Analysis extends ChangeNotifier with Repository<Chart>, RepositoryStorage<Chart>, RepositoryOrderable<Chart> {
  static late Analysis instance;

  @override
  final Stores storageStore = Stores.analysis;

  Analysis() {
    instance = this;
  }

  @override
  Chart buildItem(String id, Map<String, Object?> value) {
    return Chart.fromObject(ChartObject.build({'id': id, ...value}));
  }
}
