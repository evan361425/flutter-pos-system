import 'package:flutter/material.dart';
import 'package:possystem/settings/setting.dart';

class ThemeSetting extends Setting<ThemeMode> {
  @override
  String get key => 'theme';

  @override
  bool get registryForApp => true;

  @override
  void initialize() {
    value = ThemeMode.values[service.get<int>(key) ?? 0];
  }

  @override
  Future<void> updateRemotely(ThemeMode data) {
    return service.set<int>(key, value.index);
  }
}
