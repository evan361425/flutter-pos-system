import 'package:possystem/models/analysis/chart_object.dart';
import 'package:possystem/models/analysis/analysis.dart';
import 'package:possystem/models/model.dart';
import 'package:possystem/models/repository/seller.dart';

enum AnalysisChartType { cartesian, circular }

class CartesianChart extends Chart<OrderMetricPerDay> {
  @override
  final AnalysisChartType type = AnalysisChartType.cartesian;

  /// Which metrics to show, price, cost, or revenue
  List<OrderMetricsType> types;

  CartesianChart({
    String? id,
    ModelStatus status = ModelStatus.normal,
    String name = 'cartesian chart',
    OrderChartRange range = OrderChartRange.sevenDays,
    bool withToday = false,
    bool ignoreEmpty = true,
    this.types = const [OrderMetricsType.revenue],
  }) : super(id, name, status,
            range: range, withToday: withToday, ignoreEmpty: ignoreEmpty);

  factory CartesianChart.fromObject(CartesianChartObject object) {
    return CartesianChart(
      id: object.id,
      name: object.name ?? 'chart',
      withToday: object.withToday ?? false,
      ignoreEmpty: object.ignoreEmpty ?? true,
      types: object.types ?? const [OrderMetricsType.revenue],
      range: object.range ?? OrderChartRange.sevenDays,
    );
  }

  @override
  CartesianChartObject toObject() {
    return CartesianChartObject(
      id: id,
      name: name,
      withToday: withToday,
      ignoreEmpty: ignoreEmpty,
      types: types,
      range: range,
    );
  }

  @override
  Future<List<OrderMetricPerDay>> loader(DateTime start, DateTime end) {
    return Seller.instance.getMetricsInPeriod(
      start,
      end,
      types: types,
      period: range.period,
      fulfillAll: !ignoreEmpty,
    );
  }
}

class CircularChart extends Chart<OrderMetricPerItem> {
  @override
  final AnalysisChartType type = AnalysisChartType.circular;

  /// Which target to show, product, category, or ingredients
  CircularChartTarget target;

  /// Targets, ID of product, category, or ingredients
  List<String> selection;

  /// Whether show all data
  bool isAll;

  CircularChart({
    String? id,
    ModelStatus status = ModelStatus.normal,
    String name = 'circular chart',
    OrderChartRange range = OrderChartRange.sevenDays,
    bool withToday = false,
    bool ignoreEmpty = true,
    this.target = CircularChartTarget.product,
    this.selection = const [],
    this.isAll = false,
  }) : super(id, name, status,
            range: range, withToday: withToday, ignoreEmpty: ignoreEmpty);

  factory CircularChart.fromObject(CircularChartObject object) {
    return CircularChart(
      id: object.id,
      name: object.name ?? 'pie',
      target: object.target ?? CircularChartTarget.product,
      selection: object.selection ?? [],
      isAll: object.isAll ?? false,
    );
  }

  @override
  CircularChartObject toObject() {
    return CircularChartObject(
      id: id,
      name: name,
      target: target,
      selection: selection,
      isAll: isAll,
    );
  }

  @override
  Future<List<OrderMetricPerItem>> loader(DateTime start, DateTime end) {
    return Seller.instance.getMetricsByItems(
      start,
      end,
      item: target.itemMetrics,
      selection: selection,
    );
  }
}

enum CircularChartTarget {
  product,
  catalog,
  ingredient;

  OrderItemMetrics get itemMetrics {
    switch (this) {
      case CircularChartTarget.product:
        return OrderItemMetrics.product;
      case CircularChartTarget.catalog:
        return OrderItemMetrics.catalog;
      case CircularChartTarget.ingredient:
        return OrderItemMetrics.ingredient;
    }
  }
}
