import 'package:possystem/services/cache.dart';

/// Credentials and toggles for the external e-commerce / cloud backend.
///
/// Persisted in [Cache] (SharedPreferences), not SQLite — same pattern as other
/// operator settings. Product ID translations live in `product_mappings`.
class CloudConfig {
  const CloudConfig({
    this.storeUrl = '',
    this.apiKey = '',
    this.isActive = false,
  });

  final String storeUrl;
  final String apiKey;
  final bool isActive;

  bool get isConfigured =>
      isActive && storeUrl.trim().isNotEmpty && apiKey.trim().isNotEmpty;

  CloudConfig copyWith({
    String? storeUrl,
    String? apiKey,
    bool? isActive,
  }) {
    return CloudConfig(
      storeUrl: storeUrl ?? this.storeUrl,
      apiKey: apiKey ?? this.apiKey,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, Object?> toMap() => {
    'storeUrl': storeUrl,
    'apiKey': apiKey,
    'isActive': isActive,
  };

  static const _keyStoreUrl = 'cloud.storeUrl';
  static const _keyApiKey = 'cloud.apiKey';
  static const _keyIsActive = 'cloud.isActive';

  /// Load from [Cache]; returns an inactive empty config if unset.
  static CloudConfig load([Cache? cache]) {
    final c = cache ?? Cache.instance;
    return CloudConfig(
      storeUrl: c.get<String>(_keyStoreUrl) ?? '',
      apiKey: c.get<String>(_keyApiKey) ?? '',
      isActive: c.get<bool>(_keyIsActive) ?? false,
    );
  }

  /// Persist to [Cache]. Does not log the API key value (Law 5.7).
  Future<void> save([Cache? cache]) async {
    final c = cache ?? Cache.instance;
    await c.set<String>(_keyStoreUrl, storeUrl);
    await c.set<String>(_keyApiKey, apiKey);
    await c.set<bool>(_keyIsActive, isActive);
  }
}
