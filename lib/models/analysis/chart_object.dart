import 'package:possystem/models/analysis/analysis.dart';
import 'package:possystem/models/analysis/chart.dart';
import 'package:possystem/models/model_object.dart';
import 'package:possystem/models/repository/seller.dart';

class ChartObject<T extends Chart> extends ModelObject<T> {
  final AnalysisChartType type;
  final String? id;
  final String? name;
  final OrderChartRange? range;
  final bool? withToday;
  final bool? ignoreEmpty;
  final OrderMetricTarget? target;
  final List<OrderMetricType>? metrics;
  final List<String>? targetItems;

  const ChartObject({
    this.type = AnalysisChartType.cartesian,
    this.id,
    this.name,
    this.range,
    this.withToday,
    this.ignoreEmpty,
    this.target,
    this.metrics,
    this.targetItems,
  });

  factory ChartObject.build(Map<String, Object?> map) {
    return ChartObject(
      id: map['id'] as String?,
      name: map['name'] as String?,
      range: OrderChartRange.values[map['range'] as int? ?? 0],
      withToday: map['withToday'] as bool?,
      ignoreEmpty: map['ignoreEmpty'] as bool?,
      target: OrderMetricTarget.values[map['target'] as int? ?? 0],
      metrics: (map['metrics'] as List?)
          ?.map((e) => OrderMetricType.values[e as int])
          .toList(),
      targetItems: map['targetItems'] as List<String>?,
    );
  }

  @override
  Map<String, Object?> toMap() {
    return {
      'type': type.index,
      'name': name,
      'range': range?.index,
      'withToday': withToday,
      'ignoreEmpty': ignoreEmpty,
      'target': target?.index,
      'metrics': metrics?.map((e) => e.index).toList(),
      'targetItems': targetItems,
    };
  }

  @override
  Map<String, Object?> diff(T model) {
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
    if (target != null && target != model.target) {
      model.target = target!;
      result['$prefix.target'] = target!.index;
    }
    if (targetItems != null &&
        targetItems!.join('') != model.targetItems.join('')) {
      model.targetItems = targetItems!;
      result['$prefix.targetItems'] = targetItems!;
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
