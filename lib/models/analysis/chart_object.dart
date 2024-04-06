import 'package:possystem/models/analysis/chart.dart';
import 'package:possystem/models/model_object.dart';
import 'package:possystem/models/repository/seller.dart';

class ChartObject<T extends Chart> extends ModelObject<T> {
  final String? id;
  final String? name;
  final int? index;
  final AnalysisChartType? type;
  final bool? ignoreEmpty;
  final OrderMetricTarget? target;
  final List<OrderMetricType>? metrics;
  final List<String>? targetItems;

  const ChartObject({
    this.id,
    this.name,
    this.index,
    this.type,
    this.ignoreEmpty,
    this.target,
    this.metrics,
    this.targetItems,
  });

  factory ChartObject.build(Map<String, Object?> map) {
    return ChartObject(
      id: map['id'] as String?,
      name: map['name'] as String?,
      index: map['index'] as int?,
      type: AnalysisChartType.values[map['type'] as int? ?? 0],
      ignoreEmpty: map['ignoreEmpty'] as bool?,
      target: OrderMetricTarget.values[map['target'] as int? ?? 0],
      metrics: (map['metrics'] as List?)?.map((e) => OrderMetricType.values[e as int]).toList(),
      targetItems: (map['targetItems'] as List?)?.cast<String>(),
    );
  }

  @override
  Map<String, Object?> toMap() {
    return {
      'name': name,
      'index': index,
      'type': type?.index,
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
    if (type != null && type != model.type) {
      model.type = type!;
      result['$prefix.type'] = type!.index;
    }
    if (ignoreEmpty != null && ignoreEmpty != model.ignoreEmpty) {
      model.ignoreEmpty = ignoreEmpty!;
      result['$prefix.ignoreEmpty'] = ignoreEmpty!;
    }
    if (target != null && target != model.target) {
      model.target = target!;
      result['$prefix.target'] = target!.index;
    }
    if (metrics != null && metrics!.join('') != model.metrics.join('')) {
      model.metrics = metrics!;
      result['$prefix.metrics'] = metrics!.map((e) => e.index).toList();
    }
    if (targetItems != null && targetItems!.join('') != model.targetItems.join('')) {
      model.targetItems = targetItems!;
      result['$prefix.targetItems'] = targetItems!;
    }

    return result;
  }
}
