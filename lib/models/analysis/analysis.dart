import 'package:flutter/foundation.dart';
import 'package:possystem/models/analysis/chart.dart';
import 'package:possystem/models/analysis/chart_object.dart';
import 'package:possystem/models/model.dart';
import 'package:possystem/models/model_object.dart';
import 'package:possystem/models/repository.dart';
import 'package:possystem/services/storage.dart';

class Analysis extends ChangeNotifier
    with Repository<Chart>, RepositoryStorage<Chart> {
  static late Analysis instance;

  @override
  final Stores storageStore = Stores.analysis;

  Analysis() {
    instance = this;
  }

  @override
  Chart buildItem(String id, Map<String, Object?> value) {
    final type = AnalysisChartType.values[(value['type'] as int?) ?? 0];

    switch (type) {
      case AnalysisChartType.cartesian:
        return CartesianChart.fromObject(
          CartesianChartObject.build({
            'id': id,
            ...value,
          }),
        );
      case AnalysisChartType.circular:
        return CircularChart.fromObject(
          CircularChartObject.build({
            'id': id,
            ...value,
          }),
        );
    }
  }
}

abstract class Chart<T> extends Model<ModelObject>
    with ModelStorage<ModelObject> {
  abstract final AnalysisChartType type;

  /// Which range to show, for example 7 days, 30 days, or 365 days
  OrderChartRange range;

  /// Whether show today's data
  bool withToday;

  /// Whether ignore empty data
  bool ignoreEmpty;

  Chart(
    String? id,
    String name,
    ModelStatus status, {
    required this.range,
    required this.withToday,
    required this.ignoreEmpty,
  }) : super(id, name, status);

  @override
  Stores get storageStore => Stores.analysis;

  @override
  Analysis get repository => Analysis.instance;

  @override
  set repository(Repository repo) {}

  Future<List<T>> loader(DateTime start, DateTime end);
}
