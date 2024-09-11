import 'package:flutter/material.dart';
import 'package:possystem/settings/checkout_warning.dart';
import 'package:possystem/settings/collect_events_setting.dart';

import 'currency_setting.dart';
import 'language_setting.dart';
import 'order_awakening_setting.dart';
import 'setting.dart';
import 'theme_setting.dart';

class SettingsProvider extends ChangeNotifier {
  static SettingsProvider instance = SettingsProvider._();

  final settings = List<Setting>.from(<Setting>[
    LanguageSetting.instance,
    ThemeSetting.instance,
    CurrencySetting.instance,
    OrderAwakeningSetting.instance,
    CheckoutWarningSetting.instance,
    CollectEventsSetting.instance,
  ], growable: false);

  SettingsProvider._();

  void initialize() {
    for (var setting in settings) {
      setting.initialize();
      if (setting.registryForApp) {
        setting.addListener(notifyListeners);
      }
    }
  }
}
