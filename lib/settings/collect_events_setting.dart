import 'package:possystem/helpers/logger.dart';
import 'package:possystem/settings/setting.dart';

class CollectEventsSetting extends Setting<bool> {
  @override
  String get key => 'feat.collectEvents';

  @override
  void initialize() {
    value = service.get<bool>(key) ?? true;
  }

  @override
  Future<void> updateRemotely(bool data) {
    Log.allowSendEvents = data;
    return service.set<bool>(key, data);
  }
}
