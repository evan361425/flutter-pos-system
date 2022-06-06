import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:possystem/debug/setup_menu.dart';
import 'package:possystem/firebase_options.dart';
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
import 'settings/settings_provider.dart';
import 'ui/home/home_scaffold.dart';

void main() async {
  // https://stackoverflow.com/questions/57689492/flutter-unhandled-exception-servicesbinding-defaultbinarymessenger-was-accesse
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Not all errors are caught by Flutter. Sometimes, errors are instead caught by Zones.
  await runZonedGuarded<Future<void>>(() async {
    // Pass all uncaught errors from the framework to Crashlytics.
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

    if (kDebugMode) {
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false);
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
    }

    await Database.instance.initialize();
    await Storage.instance.initialize();
    await Cache.instance.initialize();

    final settings = SettingsProvider(SettingsProvider.allSettings);

    await Stock().initialize();
    await Quantities().initialize();
    await CustomerSettings().initialize();
    await Replenisher().initialize();
    await Cashier().reset();
    // Last for setup ingredient and quantity
    await Menu().initialize();

    await Database.instance.tolerateMigration();

    if (kDebugMode) {
      await debugSetupMenu();
    }

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
          create: (_) => Cashier.instance,
        ),
      ],
      child: MyApp(
        settings: settings,
        child: const HomeScaffold(),
      ),
    ));
  }, FirebaseCrashlytics.instance.recordError);
}
