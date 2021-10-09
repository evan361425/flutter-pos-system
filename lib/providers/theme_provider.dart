import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/services/cache.dart';

class ThemeProvider extends ChangeNotifier {
  static bool get defaultTheme =>
      SchedulerBinding.instance?.window.platformBrightness == Brightness.dark;

  ThemeMode? _mode;

  ThemeMode get mode => _mode!;

  void initialize() {
    if (_mode != null) return;

    // get from cache, if not found get system setting
    final value = Cache.instance.get<int>(Caches.dark_mode);
    _mode = ThemeMode.values[value ?? ThemeMode.system.index];
  }

  Future<void> setMode(ThemeMode value) async {
    info(value.toString(), 'setting.theme');
    await Cache.instance.set<int>(Caches.dark_mode, value.index);

    if (_mode != value) {
      _mode = value;
      notifyListeners();
    }
  }
}
