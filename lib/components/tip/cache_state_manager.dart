import 'package:possystem/services/cache.dart';
import 'package:simple_tip/simple_tip.dart';

class CacheStateManager extends StateManager {
  static final CacheStateManager instance = CacheStateManager._();

  CacheStateManager._();

  /// tip 問題很多 https://github.com/evan361425/flutter-pos-system/issues/new
  /// 先關掉，等都解決再來玩玩
  @override
  bool shouldShow(String groupId, TipItem item) {
    return false;
    // if (item.version == 0) return false;

    // final cachedVersion = Cache.instance.get<int>('_tip.$groupId.${item.id}');
    // return cachedVersion == null ? true : cachedVersion < item.version;
  }

  @override
  Future<void> tipRead(String groupId, TipItem item) {
    return Cache.instance.set<int>('_tip.$groupId.${item.id}', item.version);
  }

  static void initialize() {
    TipGrouper.defaultStateManager = CacheStateManager.instance;
  }
}
