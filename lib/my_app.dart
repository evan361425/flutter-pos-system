import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:possystem/components/tip/cache_state_manager.dart';
import 'package:possystem/constants/app_themes.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/providers/currency_provider.dart';
import 'package:possystem/providers/language_provider.dart';
import 'package:possystem/providers/theme_provider.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/services/cache.dart';
import 'package:possystem/services/database.dart';
import 'package:possystem/services/storage.dart';
import 'package:possystem/ui/home/home_screen.dart';
import 'package:possystem/ui/model_initializer.dart';
import 'package:possystem/ui/splash/welcome_splash.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  static final analytics = FirebaseAnalytics();

  static final routeObserver = RouteObserver<ModalRoute<void>>();

  static bool _isLoadedSettings = false;

  static bool _isRegistedServices = false;

  final bool isDebug;

  const MyApp({Key? key, this.isDebug = kDebugMode}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final language = context.watch<LanguageProvider>();
    final currency = context.watch<CurrencyProvider>();

    if (_isRegistedServices && !_isLoadedSettings) {
      theme.initialize();
      language.initialize();
      currency.initialize();
      _isLoadedSettings = true;
    }

    return MaterialApp(
      title: 'POS System',
      routes: Routes.routes,
      debugShowCheckedModeBanner: false,
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
        routeObserver,
      ],
      // === language setting ===
      locale: language.isReady ? language.locale : null,
      supportedLocales: LanguageProvider.supports,
      localizationsDelegates: LanguageProvider.delegates,
      localeListResolutionCallback: language.localeListResolutionCallback,
      // === theme setting ===
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: theme.isReady ? theme.mode : null,
      // === home widget ===
      home: FutureBuilder<bool>(
        future: _registerServices(context),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            error('${snapshot.error}', 'initialize', snapshot.stackTrace);
          }

          return _isRegistedServices
              ? ModelIntializer(child: HomeScreen())
              : WelcomeSplash();
        },
      ),
    );
  }

  Future<bool> _registerServices(BuildContext context) async {
    if (_isRegistedServices) {
      return true;
    }

    if (isDebug) {
      await analytics.setAnalyticsCollectionEnabled(false);
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
    }

    await Database.instance.initialize();
    await Storage.instance.initialize();
    await Cache.instance.initialize();
    CacheStateManager.initialize();

    _isRegistedServices = true;

    // rebuild app
    LanguageProvider.instance.translatorFilesChanged();

    return true;
  }
}
