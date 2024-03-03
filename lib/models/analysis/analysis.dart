import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:possystem/models/analysis/chart.dart';
import 'package:possystem/models/analysis/chart_object.dart';
import 'package:possystem/models/model.dart';
import 'package:possystem/models/model_object.dart';
import 'package:possystem/models/repository.dart';
import 'package:possystem/models/repository/seller.dart';
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
    final object = ChartObject.build({'id': id, ...value});

    switch (type) {
      case AnalysisChartType.cartesian:
        return CartesianChart.fromObject(object);
      case AnalysisChartType.circular:
        return CircularChart.fromObject(object);
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

  /// Which target to show, product, category, or ingredients
  OrderMetricTarget target;

  /// Which metrics to show, price, cost, or revenue
  List<OrderMetricType> metrics;

  /// Target's specified items IDs.
  List<String> targetItems;

  Chart({
    super.id,
    required super.name,
    required super.status,
    required this.range,
    required this.withToday,
    required this.ignoreEmpty,
    required this.metrics,
    required this.target,
    required this.targetItems,
  });

  @override
  Stores get storageStore => Stores.analysis;

  @override
  Analysis get repository => Analysis.instance;

  @override
  set repository(Repository repo) {}

  @override
  ChartObject toObject() {
    return ChartObject(
      type: type,
      id: id,
      name: name,
      range: range,
      withToday: withToday,
      ignoreEmpty: ignoreEmpty,
      target: target,
      metrics: metrics,
      targetItems: targetItems,
    );
  }

  /// Load the metrics from the database
  Future<List<T>> loader(DateTime start, DateTime end);

  Iterable<OrderMetricUnit> get units {
    return metrics
        .groupFoldBy<OrderMetricUnit, int>((e) => e.unit, (prev, current) => 0)
        .keys;
  }
}
