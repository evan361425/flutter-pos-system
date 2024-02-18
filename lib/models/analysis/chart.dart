import 'package:possystem/models/analysis/chart_object.dart';
import 'package:possystem/models/analysis/analysis.dart';
import 'package:possystem/models/model.dart';
import 'package:possystem/models/repository/seller.dart';

enum AnalysisChartType { cartesian, circular }

class CartesianChart extends Chart<OrderMetricPerDay> {
  @override
  final AnalysisChartType type = AnalysisChartType.cartesian;

  /// Which metrics to show, price, cost, or revenue
  List<OrderMetricType> metrics;

  /// Which target to show, product, category, or ingredients
  OrderMetricTarget? target;

  /// Target's IDs of product, category, or ingredients
  List<String> selection;

  CartesianChart({
    String? id,
    ModelStatus status = ModelStatus.normal,
    String name = 'cartesian chart',
    OrderChartRange range = OrderChartRange.sevenDays,
    bool withToday = false,
    bool ignoreEmpty = true,
    this.metrics = const [OrderMetricType.revenue],
    this.target = OrderMetricTarget.product,
    this.selection = const [],
  }) : super(id, name, status,
            range: range, withToday: withToday, ignoreEmpty: ignoreEmpty);

  factory CartesianChart.fromObject(CartesianChartObject object) {
    return CartesianChart(
      id: object.id,
      name: object.name ?? 'chart',
      metrics: object.metrics ?? const [OrderMetricType.revenue],
      target: object.target,
      selection: object.selection ?? const <String>[],
      range: object.range ?? OrderChartRange.sevenDays,
      withToday: object.withToday ?? false,
      ignoreEmpty: object.ignoreEmpty ?? true,
    );
  }

  @override
  CartesianChartObject toObject() {
    return CartesianChartObject(
      id: id,
      name: name,
      metrics: metrics,
      target: target,
      selection: selection,
      range: range,
      withToday: withToday,
      ignoreEmpty: ignoreEmpty,
    );
  }

  @override
  Future<List<OrderMetricPerDay>> loader(DateTime start, DateTime end) {
    return Seller.instance.getMetricsInPeriod(
      start,
      end,
      types: metrics,
      period: range.period,
      fulfillAll: !ignoreEmpty,
    );
  }
}

class CircularChart extends Chart<OrderMetricPerItem> {
  @override
  final AnalysisChartType type = AnalysisChartType.circular;

  /// Which target to show, product, category, or ingredients
  OrderMetricTarget target;

  /// Target's IDs of product, category, or ingredients
  List<String> selection;

  /// Show [groupTo]-largest items and group the rest
  int groupTo;

  CircularChart({
    String? id,
    ModelStatus status = ModelStatus.normal,
    String name = 'circular chart',
    OrderChartRange range = OrderChartRange.sevenDays,
    bool withToday = false,
    bool ignoreEmpty = true,
    this.target = OrderMetricTarget.product,
    this.selection = const [],
    this.groupTo = 5,
  }) : super(id, name, status,
            range: range, withToday: withToday, ignoreEmpty: ignoreEmpty);

  factory CircularChart.fromObject(CircularChartObject object) {
    return CircularChart(
      id: object.id,
      name: object.name ?? 'pie',
      target: object.target ?? OrderMetricTarget.product,
      selection: object.selection ?? [],
      groupTo: object.groupTo ?? 5,
      range: object.range ?? OrderChartRange.sevenDays,
      withToday: object.withToday ?? false,
      ignoreEmpty: object.ignoreEmpty ?? true,
    );
  }

  @override
  CircularChartObject toObject() {
    return CircularChartObject(
      id: id,
      name: name,
      target: target,
      selection: selection,
      groupTo: groupTo,
      range: range,
      withToday: withToday,
      ignoreEmpty: ignoreEmpty,
    );
  }

  @override
  Future<List<OrderMetricPerItem>> loader(DateTime start, DateTime end) {
    return Seller.instance.getMetricsByItems(
      start,
      end,
      item: target,
      selection: selection,
    );
  }
}
