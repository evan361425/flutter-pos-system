import 'package:possystem/models/analysis/chart.dart';
import 'package:possystem/models/model_object.dart';
import 'package:possystem/models/repository/seller.dart';

class CartesianChartObject extends ModelObject<CartesianChart> {
  final String? id;
  final String? name;
  final bool? withToday;
  final bool? ignoreEmpty;
  final List<OrderMetricsType>? types;
  final OrderChartRange? range;

  const CartesianChartObject({
    this.id,
    this.name,
    this.withToday,
    this.ignoreEmpty,
    this.types,
    this.range,
  });

  factory CartesianChartObject.build(Map<String, Object?> map) {
    return CartesianChartObject(
      id: map['id'] as String?,
      name: map['name'] as String?,
      withToday: map['withToday'] as bool?,
      ignoreEmpty: map['ignoreEmpty'] as bool?,
      types: (map['types'] as List?)
          ?.map((e) => OrderMetricsType.values[e as int])
          .toList(),
      range: OrderChartRange.values[map['range'] as int? ?? 0],
    );
  }

  @override
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'withToday': withToday,
      'ignoreEmpty': ignoreEmpty,
      'types': types?.map((e) => e.index).toList(),
      'range': range?.index,
      'type': AnalysisChartType.cartesian.index,
    };
  }

  @override
  Map<String, Object> diff(CartesianChart model) {
    final result = <String, Object>{};

    if (name != null && name != model.name) {
      model.name = name!;
      result['name'] = name!;
    }
    if (withToday != null && withToday != model.withToday) {
      model.withToday = withToday!;
      result['withToday'] = withToday!;
    }
    if (ignoreEmpty != null && ignoreEmpty != model.ignoreEmpty) {
      model.ignoreEmpty = ignoreEmpty!;
      result['ignoreEmpty'] = ignoreEmpty!;
    }
    if (types != null && types!.join('') != model.types.join('')) {
      model.types = types!;
      result['types'] = types!.map((e) => e.index).toList();
    }
    if (range != null && range != model.range) {
      model.range = range!;
      result['range'] = range!.index;
    }

    return result;
  }
}

class CircularChartObject extends ModelObject<CircularChart> {
  final String? id;
  final String? name;
  final CircularChartTarget? target;
  final List<String>? selection;
  final OrderChartRange? range;
  final bool? isAll;
  final bool? withToday;

  const CircularChartObject({
    this.id,
    this.name,
    this.target,
    this.selection,
    this.range,
    this.isAll,
    this.withToday,
  });

  factory CircularChartObject.build(Map<String, Object?> map) {
    return CircularChartObject(
      id: map['id'] as String?,
      name: map['name'] as String?,
      target: CircularChartTarget.values[map['target'] as int? ?? 0],
      selection: map['targets'] as List<String>?,
      range: OrderChartRange.values[map['range'] as int? ?? 0],
      isAll: map['isAll'] as bool?,
      withToday: map['withToday'] as bool?,
    );
  }

  @override
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'target': target?.index,
      'selection': selection,
      'range': range?.index,
      'isAll': isAll,
      'withToday': withToday,
      'type': AnalysisChartType.circular.index,
    };
  }

  @override
  Map<String, Object> diff(CircularChart model) {
    final result = <String, Object>{};

    if (name != null && name != model.name) {
      model.name = name!;
      result['name'] = name!;
    }
    if (target != null && target != model.target) {
      model.target = target!;
      result['target'] = target!.index;
    }
    if (range != null && range != model.range) {
      model.range = range!;
      result['range'] = range!.index;
    }
    if (isAll != null && isAll != model.isAll) {
      model.isAll = isAll!;
      result['isAll'] = isAll!;
    }
    if (withToday != null && withToday != model.withToday) {
      model.withToday = withToday!;
      result['withToday'] = withToday!;
    }
    if (selection != null && selection!.join('') != model.selection.join('')) {
      model.selection = selection!;
      result['selection'] = selection!;
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
  final MetricsPeriod period;

  const OrderChartRange(this.duration, this.period);
}
