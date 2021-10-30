import 'package:possystem/settings/setting.dart';

class OrderAwakeningSetting extends Setting<bool> {
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
