import 'package:possystem/settings/setting.dart';

class OrderAwakeningSetting extends Setting<bool> {
  static final instance = OrderAwakeningSetting._();

  OrderAwakeningSetting._();

  @override
  String get key => 'feat.orderAwakening';

  @override
  void initialize() {
    value = service.get<bool>(key) ?? true;
  }

  @override
  Future<void> updateRemotely(bool data) {
    return service.set<bool>(key, data);
  }
}
