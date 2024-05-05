import 'package:possystem/settings/setting.dart';

class OrderProductAxisCountSetting extends Setting<int> {
  static final instance = OrderProductAxisCountSetting._();

  OrderProductAxisCountSetting._();

  @override
  String get key => 'feat.orderProductAxisCount';

  @override
  void initialize() {
    value = service.get<int>(key) ?? 2;
  }

  @override
  Future<void> updateRemotely(int data) {
    return service.set<int>(key, data);
  }
}
