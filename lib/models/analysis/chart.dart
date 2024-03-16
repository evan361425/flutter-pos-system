import 'package:collection/collection.dart';
import 'package:possystem/models/analysis/analysis.dart';
import 'package:possystem/models/analysis/chart_object.dart';
import 'package:possystem/models/model.dart';
import 'package:possystem/models/repository.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/services/storage.dart';

enum AnalysisChartType { cartesian, circular }

class Chart extends Model<ChartObject> with ModelStorage<ChartObject> {
  /// Which type of chart to show, for example, cartesian or circular
  AnalysisChartType type;

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
    super.name = 'chart',
    super.status = ModelStatus.normal,
    this.type = AnalysisChartType.cartesian,
    this.range = OrderChartRange.sevenDays,
    this.withToday = false,
    this.ignoreEmpty = false,
    this.target = OrderMetricTarget.order,
    this.metrics = const [OrderMetricType.price],
    this.targetItems = const [],
  });

  factory Chart.fromObject(ChartObject object) {
    return Chart(
      id: object.id,
      name: object.name ?? 'chart',
      type: object.type ?? AnalysisChartType.cartesian,
      range: object.range ?? OrderChartRange.sevenDays,
      withToday: object.withToday ?? false,
      ignoreEmpty: object.ignoreEmpty ?? false,
      target: object.target ?? OrderMetricTarget.order,
      metrics: object.metrics ?? const [OrderMetricType.price],
      targetItems: object.targetItems ?? const <String>[],
    );
  }

  @override
  Stores get storageStore => Stores.analysis;

  @override
  Analysis get repository => Analysis.instance;

  @override
  set repository(Repository repo) {}

  @override
  ChartObject toObject() {
    return ChartObject(
      id: id,
      name: name,
      type: type,
      range: range,
      withToday: withToday,
      ignoreEmpty: ignoreEmpty,
      target: target,
      metrics: metrics,
      targetItems: targetItems,
    );
  }

  Iterable<OrderMetricUnit> get units {
    return metrics
        .groupFoldBy<OrderMetricUnit, int>((e) => e.unit, (prev, current) => 0)
        .keys;
  }

  /// Get the name and unit of each metric in the chart.
  Iterable<MapEntry<String, OrderMetricUnit>> keyUnits() {
    if (target == OrderMetricTarget.order) {
      return metrics.map((e) => MapEntry(e.name, e.unit));
    }

    final unit = metrics.first.unit;
    return target
        .getItems(targetItems)
        .map(target.isGroupedName(targetItems)
            ? (e) => '${e.name}(${(e.repository as Model).name})'
            : (e) => e.name)
        .map((e) => MapEntry(e, unit));
  }

  Future<List> load(DateTime start, DateTime end) {
    switch (type) {
      case AnalysisChartType.cartesian:
        return _loadCartesian(start, end);
      case AnalysisChartType.circular:
        return _loadCircular(start, end);
    }
  }

  Future<List<OrderDataPerDay>> _loadCartesian(DateTime start, DateTime end) {
    return target == OrderMetricTarget.order
        ? Seller.instance.getMetricsInPeriod(
            start,
            end,
            types: metrics,
            period: range.period,
            ignoreEmpty: ignoreEmpty,
          )
        : Seller.instance.getItemMetricsInPeriod(
            start,
            end,
            target: target,
            type: metrics.first,
            selection: targetItems,
            period: range.period,
            ignoreEmpty: ignoreEmpty,
          );
  }

  Future<List<OrderMetricPerItem>> _loadCircular(
      DateTime start, DateTime end) async {
    return Seller.instance.getMetricsByItems(
      start,
      end,
      target: target,
      type: metrics.first,
      selection: targetItems,
      ignoreEmpty: ignoreEmpty,
    );
  }
}
