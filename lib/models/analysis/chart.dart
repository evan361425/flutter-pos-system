import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:possystem/models/analysis/analysis.dart';
import 'package:possystem/models/analysis/chart_object.dart';
import 'package:possystem/models/model.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/services/storage.dart';

enum AnalysisChartType { cartesian, circular }

class Chart extends Model<ChartObject> with ModelStorage<ChartObject>, ModelOrderable<ChartObject> {
  /// Which type of chart to show, for example, cartesian or circular
  AnalysisChartType type;

  /// Whether ignore empty data
  bool ignoreEmpty;

  /// Which target to show, product, category, or ingredients
  OrderMetricTarget target;

  /// Which metrics to show, revenue, cost, or profit
  List<OrderMetricType> metrics;

  /// Target's specified items IDs.
  List<String> targetItems;

  Chart({
    super.id,
    super.name = 'chart',
    super.status = ModelStatus.normal,
    int index = 0,
    this.type = AnalysisChartType.cartesian,
    this.ignoreEmpty = false,
    this.target = OrderMetricTarget.order,
    this.metrics = const [OrderMetricType.revenue],
    this.targetItems = const [],
  }) {
    this.index = index;
  }

  factory Chart.fromObject(ChartObject object) {
    return Chart(
      id: object.id,
      name: object.name ?? 'chart',
      index: object.index ?? 0,
      type: object.type ?? AnalysisChartType.cartesian,
      ignoreEmpty: object.ignoreEmpty ?? false,
      target: object.target ?? OrderMetricTarget.order,
      metrics: object.metrics ?? const [OrderMetricType.revenue],
      targetItems: object.targetItems ?? const <String>[],
    );
  }

  @override
  Stores get storageStore => Stores.analysis;

  @override
  Analysis get repository => Analysis.instance;

  @override
  ChartObject toObject() {
    return ChartObject(
      id: id,
      name: name,
      index: index,
      type: type,
      ignoreEmpty: ignoreEmpty,
      target: target,
      metrics: metrics,
      targetItems: targetItems,
    );
  }

  Iterable<OrderMetricUnit> get units {
    return metrics.groupFoldBy<OrderMetricUnit, int>((e) => e.unit, (prev, current) => 0).keys;
  }

  /// Get the name and unit of each metric in the chart.
  Iterable<MapEntry<String, OrderMetricUnit>> keyUnits() {
    if (target == OrderMetricTarget.order) {
      return metrics.map((e) => MapEntry(e.name, e.unit));
    }

    final unit = metrics.first.unit;
    return target
        .getItems(targetItems)
        .map(target.isGroupedName(targetItems) ? (e) => '${e.name}(${(e.repository as Model).name})' : (e) => e.name)
        .map((e) => MapEntry(e, unit));
  }

  Future<List> load(DateTimeRange range) {
    switch (type) {
      case AnalysisChartType.cartesian:
        return _loadCartesian(range);
      case AnalysisChartType.circular:
        return _loadCircular(range);
    }
  }

  Future<List<OrderSummary>> _loadCartesian(DateTimeRange range) {
    return target == OrderMetricTarget.order
        ? Seller.instance.getMetricsInPeriod(
            range.start,
            range.end,
            types: metrics,
            ignoreEmpty: ignoreEmpty,
            interval: MetricsIntervalType.fromDays(range.duration.inDays),
          )
        : Seller.instance.getItemMetricsInPeriod(
            range.start,
            range.end,
            target: target,
            type: metrics.first,
            selection: targetItems,
            ignoreEmpty: ignoreEmpty,
            interval: MetricsIntervalType.fromDays(range.duration.inDays),
          );
  }

  Future<List<OrderMetricPerItem>> _loadCircular(DateTimeRange range) async {
    return Seller.instance.getMetricsByItems(
      range.start,
      range.end,
      target: target,
      type: metrics.first,
      selection: targetItems,
      ignoreEmpty: ignoreEmpty,
    );
  }
}
