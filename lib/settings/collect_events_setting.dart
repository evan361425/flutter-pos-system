import 'package:possystem/helpers/logger.dart';
import 'package:possystem/settings/setting.dart';

class CollectEventsSetting extends Setting<bool> {
  static final CollectEventsSetting instance = ._();

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
  Future<void> updateRemotely(bool data) async {
    Log.allowSendEvents = data;

    // Do it first to make testing easier, because the rest future will not
    // complete.
    await service.set<bool>(key, data);
  }
}
