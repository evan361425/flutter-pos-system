import 'package:possystem/settings/setting.dart';

class OrderProductAxisCountSetting extends Setting<int> {
  static final instance = OrderProductAxisCountSetting._();

  static const defaultValue = 2;

  OrderProductAxisCountSetting._() {
    value = defaultValue;
  }

  @override
  String get key => 'feat.orderProductAxisCount';

  @override
  void initialize() {
    value = service.get<int>(key) ?? defaultValue;
  }

  @override
  Future<void> updateRemotely(int data) {
    return service.set<int>(key, data);
  }
}
