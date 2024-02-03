import 'package:possystem/models/analysis/chart.dart';
import 'package:possystem/models/model_object.dart';
import 'package:possystem/models/repository/seller.dart';

class ChartObject extends ModelObject<Chart> {
  final String? id;
  final String? name;
  final bool? withToday;
  final bool? ignoreEmpty;
  final List<OrderMetricsType>? types;
  final OrderChartRange? range;

  const ChartObject({
    this.id,
    this.name,
    this.withToday,
    this.ignoreEmpty,
    this.types,
    this.range,
  });

  factory ChartObject.build(Map<String, Object?> map) {
    return ChartObject(
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
    };
  }

  @override
  Map<String, Object> diff(Chart model) {
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
