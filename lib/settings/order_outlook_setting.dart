import 'package:possystem/settings/setting.dart';

class OrderOutlookSetting extends Setting<OrderOutlookTypes> {
  @override
  String get key => 'feat.orderOutlook';

  @override
  void initialize() {
    value = OrderOutlookTypes.values[service.get<int>(key) ?? 0];
  }

  @override
  Future<void> updateRemotely(OrderOutlookTypes data) {
    return service.set<int>(key, value.index);
  }
}

enum OrderOutlookTypes {
  slidingPanel,
  singleView,
}
