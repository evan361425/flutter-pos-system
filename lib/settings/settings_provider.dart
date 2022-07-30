import 'package:flutter/material.dart';
import 'package:possystem/settings/cashier_warning.dart';
import 'package:possystem/settings/collect_events_setting.dart';

import 'currency_setting.dart';
import 'language_setting.dart';
import 'order_awakening_setting.dart';
import 'order_outlook_setting.dart';
import 'order_product_axis_count_setting.dart';
import 'setting.dart';
import 'theme_setting.dart';

class SettingsProvider extends ChangeNotifier {
  static late SettingsProvider instance;

  static final allSettings = List<Setting>.from(<Setting>[
    LanguageSetting(),
    ThemeSetting(),
    CurrencySetting(),
    OrderAwakeningSetting(),
    OrderOutlookSetting(),
    OrderProductAxisCountSetting(),
    CashierWarningSetting(),
    CollectEventsSetting(),
  ], growable: false);

  final List<Setting> settings;

  SettingsProvider(this.settings) {
    instance = this;
    for (var setting in settings) {
      setting.initialize();
      if (setting.registryForApp) {
        setting.addListener(notifyListeners);
      }
    }
  }

  T getSetting<T extends Setting>() {
    return settings.firstWhere((setting) => setting is T) as T;
  }

  static T of<T extends Setting>() => instance.getSetting<T>();
}
