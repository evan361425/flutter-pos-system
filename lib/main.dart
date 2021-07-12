import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:possystem/models/repository/menu_model.dart';
import 'package:possystem/models/repository/quantity_repo.dart';
import 'package:possystem/my_app.dart';
import 'package:possystem/providers/currency_provider.dart';
import 'package:possystem/providers/language_provider.dart';
import 'package:possystem/providers/theme_provider.dart';
import 'package:provider/provider.dart';

import 'models/repository/stock_batch_repo.dart';
import 'models/repository/stock_model.dart';

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
          ChangeNotifierProvider<MenuModel>(
            create: (_) => MenuModel(),
          ),
          ChangeNotifierProvider<StockModel>(
            create: (_) => StockModel(),
          ),
          ChangeNotifierProvider<QuantityRepo>(
            create: (_) => QuantityRepo(),
          ),
          ChangeNotifierProvider<StockBatchRepo>(
            create: (_) => StockBatchRepo(),
          ),
        ],
        child: MyApp(),
      ),
    );
  }, FirebaseCrashlytics.instance.recordError);
}
