import 'package:possystem/models/analysis/chart.dart';
import 'package:possystem/models/model_object.dart';
import 'package:possystem/models/repository/seller.dart';

class CartesianChartObject extends ModelObject<CartesianChart> {
  final String? id;
  final String? name;
  final List<OrderMetricType>? metrics;
  final OrderMetricTarget? target;
  final List<String>? selection;

  final bool? withToday;
  final bool? ignoreEmpty;
  final OrderChartRange? range;

  const CartesianChartObject({
    this.id,
    this.name,
    this.metrics,
    this.target,
    this.selection,
    this.withToday,
    this.ignoreEmpty,
    this.range,
  });

  factory CartesianChartObject.build(Map<String, Object?> map) {
    final target = map['target'] as int?;
    return CartesianChartObject(
      id: map['id'] as String?,
      name: map['name'] as String?,
      metrics: (map['metrics'] as List?)
          ?.map((e) => OrderMetricType.values[e as int])
          .toList(),
      target: target == null ? null : OrderMetricTarget.values[target],
      selection: map['selection'] as List<String>?,
      withToday: map['withToday'] as bool?,
      ignoreEmpty: map['ignoreEmpty'] as bool?,
      range: OrderChartRange.values[map['range'] as int? ?? 0],
    );
  }

  @override
  Map<String, Object?> toMap() {
    return {
      'type': AnalysisChartType.cartesian.index,
      'id': id,
      'name': name,
      'metrics': metrics?.map((e) => e.index).toList(),
      'target': target?.index,
      'selection': selection,
      'withToday': withToday,
      'ignoreEmpty': ignoreEmpty,
      'range': range?.index,
    };
  }

  @override
  Map<String, Object?> diff(CartesianChart model) {
    final result = <String, Object?>{};
    final prefix = model.prefix;

    if (name != null && name != model.name) {
      model.name = name!;
      result['$prefix.name'] = name!;
    }
    if (metrics != null && metrics!.join('') != model.metrics.join('')) {
      model.metrics = metrics!;
      result['$prefix.metrics'] = metrics!.map((e) => e.index).toList();
    }
    if (target != model.target) {
      model.target = target;
      result['$prefix.target'] = target?.index;
    }
    if (selection != null && selection!.join('') != model.selection.join('')) {
      model.selection = selection!;
      result['$prefix.selection'] = selection!;
    }
    if (withToday != null && withToday != model.withToday) {
      model.withToday = withToday!;
      result['$prefix.withToday'] = withToday!;
    }
    if (ignoreEmpty != null && ignoreEmpty != model.ignoreEmpty) {
      model.ignoreEmpty = ignoreEmpty!;
      result['$prefix.ignoreEmpty'] = ignoreEmpty!;
    }
    if (range != null && range != model.range) {
      model.range = range!;
      result['$prefix.range'] = range!.index;
    }

    return result;
  }
}

class CircularChartObject extends ModelObject<CircularChart> {
  final String? id;
  final String? name;
  final OrderMetricTarget? target;
  final List<String>? selection;
  final int? groupTo;

  final OrderChartRange? range;
  final bool? withToday;
  final bool? ignoreEmpty;

  const CircularChartObject({
    this.id,
    this.name,
    this.target,
    this.selection,
    this.groupTo,
    this.range,
    this.withToday,
    this.ignoreEmpty,
  });

  factory CircularChartObject.build(Map<String, Object?> map) {
    return CircularChartObject(
      id: map['id'] as String?,
      name: map['name'] as String?,
      target: OrderMetricTarget.values[map['target'] as int? ?? 0],
      selection: map['targets'] as List<String>?,
      groupTo: map['groupTo'] as int?,
      range: OrderChartRange.values[map['range'] as int? ?? 0],
      withToday: map['withToday'] as bool?,
      ignoreEmpty: map['ignoreEmpty'] as bool?,
    );
  }

  @override
  Map<String, Object?> toMap() {
    return {
      'type': AnalysisChartType.circular.index,
      'id': id,
      'name': name,
      'target': target?.index,
      'selection': selection,
      'groupTo': groupTo,
      'range': range?.index,
      'withToday': withToday,
      'ignoreEmpty': ignoreEmpty,
    };
  }

  @override
  Map<String, Object> diff(CircularChart model) {
    final result = <String, Object>{};
    final prefix = model.prefix;

    if (name != null && name != model.name) {
      model.name = name!;
      result['$prefix.name'] = name!;
    }
    if (target != null && target != model.target) {
      model.target = target!;
      result['$prefix.target'] = target!.index;
    }
    if (selection != null && selection!.join('') != model.selection.join('')) {
      model.selection = selection!;
      result['$prefix.selection'] = selection!;
    }
    if (groupTo != null && groupTo != model.groupTo) {
      model.groupTo = groupTo!;
      result['$prefix.groupTo'] = groupTo!;
    }
    if (range != null && range != model.range) {
      model.range = range!;
      result['$prefix.range'] = range!.index;
    }
    if (withToday != null && withToday != model.withToday) {
      model.withToday = withToday!;
      result['$prefix.withToday'] = withToday!;
    }
    if (ignoreEmpty != null && ignoreEmpty != model.ignoreEmpty) {
      model.ignoreEmpty = ignoreEmpty!;
      result['$prefix.ignoreEmpty'] = ignoreEmpty!;
    }

    return result;
  }
}

enum OrderChartRange {
  today(Duration(days: 1), MetricsPeriod.hour),
  sevenDays(Duration(days: 7), MetricsPeriod.day),
  twoWeeks(Duration(days: 14), MetricsPeriod.day),
  month(Duration(days: 30), MetricsPeriod.day),
  twoMonths(Duration(days: 60), MetricsPeriod.day),
  halfYear(Duration(days: 180), MetricsPeriod.month),
  year(Duration(days: 365), MetricsPeriod.month);

  final Duration duration;

  /// The period of the metrics, use to group the data
  final MetricsPeriod period;

  const OrderChartRange(this.duration, this.period);
}
