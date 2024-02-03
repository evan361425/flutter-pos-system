import 'package:flutter/foundation.dart';
import 'package:possystem/helpers/analysis/ema_calculator.dart';
import 'package:possystem/models/analysis/chart.dart';
import 'package:possystem/models/analysis/chart_object.dart';
import 'package:possystem/models/repository.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/services/storage.dart';

class Analysis extends ChangeNotifier
    with Repository<Chart>, RepositoryStorage<Chart> {
  static late Analysis instance;

  @override
  final Stores storageStore = Stores.analysis;

  Analysis() {
    instance = this;
  }

  @override
  Chart buildItem(String id, Map<String, Object?> value) {
    return Chart.fromObject(
      ChartObject.build({
        'id': id,
        ...value,
      }),
    );
  }

  Future<double> calculateGoal(OrderMetricsType type) async {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final metrics = await Seller.instance.getMetricsInPeriod(
      yesterday.subtract(const Duration(days: 20)),
      yesterday,
      types: [type],
    );

    final cal = EMACalculator(20);
    return cal.calculate(metrics.map((e) => e.valueFromType(type)).toList());
  }
}
