import 'package:possystem/models/analysis/chart_object.dart';
import 'package:possystem/models/analysis/analysis.dart';
import 'package:possystem/models/model.dart';
import 'package:possystem/models/repository.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/services/storage.dart';

class Chart extends Model<ChartObject> with ModelStorage<ChartObject> {
  /// Whether show today's data
  bool withToday;

  /// Whether ignore empty data
  bool ignoreEmpty;

  /// Which metrics to show, price, cost, or revenue
  List<OrderMetricsType> types;

  /// Which range to show, 7 days, 30 days, or 90 days
  OrderChartRange range;

  Chart({
    String? id,
    ModelStatus? status,
    String name = 'chart',
    this.withToday = false,
    this.ignoreEmpty = true,
    this.types = const [OrderMetricsType.revenue],
    this.range = OrderChartRange.sevenDays,
  }) : super(id, status) {
    this.name = name;
  }

  factory Chart.fromObject(ChartObject object) {
    return Chart(
      id: object.id,
      name: object.name ?? 'chart',
      withToday: object.withToday ?? false,
      ignoreEmpty: object.ignoreEmpty ?? true,
      types: object.types ?? const [OrderMetricsType.revenue],
      range: object.range ?? OrderChartRange.sevenDays,
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
      withToday: withToday,
      ignoreEmpty: ignoreEmpty,
      types: types,
      range: range,
    );
  }
}
