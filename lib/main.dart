import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/repository/cashier.dart';
import 'models/repository/customer_settings.dart';
import 'models/repository/menu.dart';
import 'models/repository/quantities.dart';
import 'models/repository/replenisher.dart';
import 'models/repository/seller.dart';
import 'models/repository/stock.dart';
import 'my_app.dart';
import 'services/cache.dart';
import 'services/database.dart';
import 'services/storage.dart';
import 'settings/currency_setting.dart';
import 'settings/language_setting.dart';
import 'settings/order_awakening_setting.dart';
import 'settings/order_outlook_setting.dart';
import 'settings/order_product_axis_count_setting.dart';
import 'settings/setting.dart';
import 'settings/theme_setting.dart';
import 'ui/home/home_scaffold.dart';

void main() async {
  // https://stackoverflow.com/questions/57689492/flutter-unhandled-exception-servicesbinding-defaultbinarymessenger-was-accesse
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Not all errors are caught by Flutter. Sometimes, errors are instead caught by Zones.
  await runZonedGuarded<Future<void>>(() async {
    // Pass all uncaught errors from the framework to Crashlytics.
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

    if (kDebugMode) {
      await MyApp.analytics.setAnalyticsCollectionEnabled(false);
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
    }

    await Database.instance.initialize();
    await Storage.instance.initialize();
    await Cache.instance.initialize();

    final settings = SettingsProvider([
      LanguageSetting(),
      ThemeSetting(),
      CurrencySetting(),
      OrderAwakeningSetting(),
      OrderOutlookSetting(),
      OrderProductAxisCountSetting(),
    ])
      ..loadSetting();

    await Stock().initialize();
    await Quantities().initialize();
    await CustomerSettings().initialize();
    await Replenisher().initialize();
    // Last for setup ingredient and quantity
    await Menu().initialize();

    /// Why use provider?
    /// https://stackoverflow.com/questions/57157823/provider-vs-inheritedwidget
    runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>.value(
          value: settings,
        ),
        ChangeNotifierProvider<Menu>(
          create: (_) => Menu.instance,
        ),
        ChangeNotifierProvider<Stock>(
          create: (_) => Stock.instance,
        ),
        ChangeNotifierProvider<Quantities>(
          create: (_) => Quantities.instance,
        ),
        ChangeNotifierProvider<Replenisher>(
          create: (_) => Replenisher.instance,
        ),
        ChangeNotifierProvider<CustomerSettings>(
          create: (_) => CustomerSettings.instance,
        ),
        ChangeNotifierProvider<Seller>(
          create: (_) => Seller(),
        ),
        ChangeNotifierProvider<Cashier>(
          create: (_) => Cashier()..reset(),
          lazy: false,
        ),
      ],
      child: MyApp(
        settings: settings,
        child: const HomeScaffold(),
      ),
    ));
  }, FirebaseCrashlytics.instance.recordError);
}
