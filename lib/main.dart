import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/repository/customer_settings.dart';
import 'models/repository/menu.dart';
import 'models/repository/quantities.dart';
import 'models/repository/replenisher.dart';
import 'models/repository/stock.dart';
import 'my_app.dart';
import 'providers/currency_provider.dart';
import 'providers/language_provider.dart';
import 'providers/theme_provider.dart';

void main() async {
  // https://stackoverflow.com/questions/57689492/flutter-unhandled-exception-servicesbinding-defaultbinarymessenger-was-accesse
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Not all errors are caught by Flutter. Sometimes, errors are instead caught by Zones.
  await runZonedGuarded<Future<void>>(() async {
    // Pass all uncaught errors from the framework to Crashlytics.
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

    runApp(
      /// Why use provider?
      /// https://stackoverflow.com/questions/57157823/provider-vs-inheritedwidget
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeProvider>(
            create: (_) => ThemeProvider(),
          ),
          ChangeNotifierProvider<LanguageProvider>(
            create: (_) => LanguageProvider(),
          ),
          ChangeNotifierProvider<CurrencyProvider>(
            create: (_) => CurrencyProvider(),
          ),
          ChangeNotifierProvider<Menu>(
            create: (_) => Menu(),
          ),
          ChangeNotifierProvider<Stock>(
            create: (_) => Stock(),
          ),
          ChangeNotifierProvider<Quantities>(
            create: (_) => Quantities(),
          ),
          ChangeNotifierProvider<Replenisher>(
            create: (_) => Replenisher(),
          ),
          ChangeNotifierProvider<CustomerSettings>(
            create: (_) => CustomerSettings(),
          ),
        ],
        child: MyApp(),
      ),
    );
  }, FirebaseCrashlytics.instance.recordError);
}
