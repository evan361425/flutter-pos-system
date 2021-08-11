import 'package:possystem/helpers/logger.dart';
import 'package:possystem/services/cache.dart';

class FeatureProvider {
  static const FeatureProvider instance = FeatureProvider._();

  const FeatureProvider._();

  /// Wheather lock awake while ordering
  ///
  /// It will stop the screen from closing, without asking any permission
  bool get awakeOrdering =>
      Cache.instance.get<bool>(Caches.feature_awake_provider) ?? true;

  Future<void> setAwakeOrdering(bool value) {
    info(value.toString(), 'setting.feature.awakeOrdering');
    return Cache.instance.set<bool>(Caches.feature_awake_provider, value);
  }

  int get outlookOrder => Cache.instance.get<int>(Caches.outlook_order) ?? 0;

  Future<void> setOutlookOrder(int index) {
    info(index.toString(), 'setting.outlook.order');
    return Cache.instance.set(Caches.outlook_order, index);
  }
}
