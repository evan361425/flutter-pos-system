import 'package:possystem/helpers/logger.dart';
import 'package:possystem/settings/setting.dart';

class CollectEventsSetting extends Setting<bool> {
  static final instance = CollectEventsSetting._();

  static const defaultValue = true;

  CollectEventsSetting._() {
    value = defaultValue;
  }

  @override
  String get key => 'feat.collectEvents';

  @override
  void initialize() {
    value = service.get<bool>(key) ?? defaultValue;
  }

  @override
  Future<void> updateRemotely(bool data) {
    Log.allowSendEvents = data;
    return service.set<bool>(key, data);
  }
}
