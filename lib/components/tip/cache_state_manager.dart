import 'package:possystem/services/cache.dart';
import 'package:simple_tip/simple_tip.dart';

class CacheStateManager extends StateManager {
  static final CacheStateManager instance = CacheStateManager._();

  CacheStateManager._();

  @override
  bool shouldShow(String groupId, OrderedTipItem item) {
    return shouldShowRaw('$groupId.${item.id}', item.version);
  }

  bool shouldShowRaw(String name, int version) {
    final cachedVersion = Cache.instance.get<int>('_tip.$name');
    return cachedVersion == null ? true : cachedVersion < version;
  }

  @override
  Future<void> tipRead(String groupId, OrderedTipItem item) {
    return tipReadRaw('$groupId.${item.id}', item.version);
  }

  Future<void> tipReadRaw(String name, int version) {
    return Cache.instance.set<int>('_tip.$name', version);
  }

  static void initialize() {
    OrderedTip.stateManager = CacheStateManager.instance;
  }
}
