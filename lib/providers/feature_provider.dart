import 'package:possystem/services/cache.dart';

class FeatureProvider {
  static const FeatureProvider instance = FeatureProvider._();

  const FeatureProvider._();

  /// Wheather lock awake while ordering
  ///
  /// It will stop the screen from closing, without asking any permission
  bool get awakeOrdering =>
      Cache.instance.get<bool>(Caches.feature_awake_provider) ?? true;

  set awakeOrdering(bool value) =>
      Cache.instance.set<bool>(Caches.feature_awake_provider, value);
}
