import 'package:possystem/models/analysis/chart_object.dart';
import 'package:possystem/models/analysis/analysis.dart';
import 'package:possystem/models/model.dart';
import 'package:possystem/models/repository/seller.dart';

enum AnalysisChartType { cartesian, circular }

class CartesianChart extends Chart<OrderDataPerDay> {
  @override
  final AnalysisChartType type = AnalysisChartType.cartesian;

  CartesianChart({
    super.id,
    super.status = ModelStatus.normal,
    super.name = 'cartesian',
    super.range = OrderChartRange.sevenDays,
    super.withToday = false,
    super.ignoreEmpty = false,
    super.target = OrderMetricTarget.order,
    super.metrics = const [OrderMetricType.price],
    super.targetItems = const [],
  });

  factory CartesianChart.fromObject(ChartObject object) {
    return CartesianChart(
      id: object.id,
      name: object.name ?? 'cartesian',
      range: object.range ?? OrderChartRange.sevenDays,
      withToday: object.withToday ?? false,
      ignoreEmpty: object.ignoreEmpty ?? false,
      target: object.target ?? OrderMetricTarget.order,
      metrics: object.metrics ?? const [OrderMetricType.price],
      targetItems: object.targetItems ?? const <String>[],
    );
  }

  @override
  Future<List<OrderDataPerDay>> loader(DateTime start, DateTime end) {
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
}

class CircularChart extends Chart<OrderMetricPerItem> {
  @override
  final AnalysisChartType type = AnalysisChartType.circular;

  CircularChart({
    super.id,
    super.status = ModelStatus.normal,
    super.name = 'circular',
    super.range = OrderChartRange.sevenDays,
    super.withToday = false,
    super.ignoreEmpty = false,
    super.target = OrderMetricTarget.catalog,
    super.metrics = const [OrderMetricType.count],
    super.targetItems = const [],
  });

  factory CircularChart.fromObject(ChartObject object) {
    return CircularChart(
      id: object.id,
      name: object.name ?? 'circular',
      range: object.range ?? OrderChartRange.sevenDays,
      withToday: object.withToday ?? false,
      ignoreEmpty: object.ignoreEmpty ?? false,
      target: object.target ?? OrderMetricTarget.catalog,
      metrics: object.metrics ?? const [OrderMetricType.count],
      targetItems: object.targetItems ?? const <String>[],
    );
  }

  @override
  Future<List<OrderMetricPerItem>> loader(DateTime start, DateTime end) async {
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
