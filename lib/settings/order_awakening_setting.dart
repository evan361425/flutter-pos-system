import 'package:possystem/settings/setting.dart';

class OrderAwakeningSetting extends Setting<bool> {
  static final instance = OrderAwakeningSetting._();

  static const defaultValue = true;

  OrderAwakeningSetting._() {
    value = defaultValue;
  }

  @override
  String get key => 'feat.orderAwakening';

  @override
  void initialize() {
    value = service.get<bool>(key) ?? defaultValue;
  }

  @override
  Future<void> updateRemotely(bool data) {
    return service.set<bool>(key, data);
  }
}
