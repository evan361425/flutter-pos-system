import 'package:possystem/settings/setting.dart';

class OrderProductAxisCountSetting extends Setting<int> {
  @override
  String get key => 'order_product_axis_count';

  @override
  void initialize() {
    value = service.get<int>(key) ?? 2;
  }

  @override
  Future<void> updateRemotely(int data) {
    return service.set<int>(key, data);
  }
}
