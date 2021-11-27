import 'package:possystem/services/cache.dart';
import 'package:simple_tip/simple_tip.dart';

class CacheStateManager extends StateManager {
  static final CacheStateManager instance = CacheStateManager._();

  CacheStateManager._();

  @override
  bool shouldShow(String groupId, TipItem item) {
    final cachedVersion = Cache.instance.get<int>('_tip.$groupId.${item.id}');
    return cachedVersion == null ? true : cachedVersion < item.version;
  }

  @override
  Future<void> tipRead(String groupId, TipItem item) {
    return Cache.instance.set<int>('_tip.$groupId.${item.id}', item.version);
  }

  static void initialize() {
    TipGrouper.defaultStateManager = CacheStateManager.instance;
  }
}
