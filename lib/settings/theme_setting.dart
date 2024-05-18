import 'package:flutter/material.dart';
import 'package:possystem/settings/setting.dart';

class ThemeSetting extends Setting<ThemeMode> {
  static final instance = ThemeSetting._();

  static const defaultValue = ThemeMode.system;

  ThemeSetting._() {
    value = defaultValue;
  }

  @override
  String get key => 'theme';

  @override
  bool get registryForApp => true;

  @override
  void initialize() {
    value = ThemeMode.values[service.get<int>(key) ?? defaultValue.index];
  }

  @override
  Future<void> updateRemotely(ThemeMode data) {
    return service.set<int>(key, value.index);
  }
}
