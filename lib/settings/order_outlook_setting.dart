import 'package:possystem/settings/setting.dart';

class OrderOutlookSetting extends Setting<OrderOutlookTypes> {
  static final instance = OrderOutlookSetting._();

  static const defaultValue = OrderOutlookTypes.slidingPanel;

  OrderOutlookSetting._() {
    value = defaultValue;
  }

  @override
  String get key => 'feat.orderOutlook';

  @override
  void initialize() {
    value = OrderOutlookTypes.values[service.get<int>(key) ?? defaultValue.index];
  }

  @override
  Future<void> updateRemotely(OrderOutlookTypes data) {
    return service.set<int>(key, value.index);
  }
}

enum OrderOutlookTypes {
  /// show order in sliding panel, recommended for mobile phone
  slidingPanel,

  /// show order in single view, recommended for tablet
  singleView,
}
