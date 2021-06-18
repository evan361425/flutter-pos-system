import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:possystem/constants/app_themes.dart';
import 'package:possystem/providers/currency_provider.dart';
import 'package:possystem/providers/language_provider.dart';
import 'package:possystem/providers/theme_provider.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/services/cache.dart';
import 'package:possystem/services/database.dart';
import 'package:possystem/services/storage.dart';
import 'package:possystem/ui/home/home_screen.dart';
import 'package:possystem/ui/splash/logo_splash.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  static final analytics = FirebaseAnalytics();

  static bool initilized = false;

  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _initialization(context),
      initialData: false,
      builder: (context, snapshot) {
        final prepared = snapshot.data!;
        final theme = context.watch<ThemeProvider>();
        final language = context.watch<LanguageProvider>();
        final currency = context.watch<CurrencyProvider>();

        if (prepared && !initilized) {
          theme.initialize();
          language.initialize();
          currency.initialize();
          initilized = true;
        }

        final pref = prepared
            ? _Preferences(
                language: language.locale,
                isDarkMode: theme.darkMode,
                currency: currency.currency)
            : _Preferences();

        return MaterialApp(
          title: 'POS System',
          routes: Routes.routes,
          debugShowCheckedModeBanner: false,
          navigatorObservers: [FirebaseAnalyticsObserver(analytics: analytics)],
          // === language setting ===
          locale: pref.language,
          supportedLocales: LanguageProvider.supports,
          localizationsDelegates: LanguageProvider.delegates,
          localeResolutionCallback: language.localResolutionCallback,
          // === theme setting ===
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: pref.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          // === home widget ===
          home: prepared ? HomeScreen() : LogoSplash(),
        );
      },
    );
  }

  Future<bool> _initialization(BuildContext context) async {
    await Database.instance.initialize();
    await Storage.instance.initialize();
    await Cache.instance.initialize();

    return true;
  }
}

class _Preferences {
  Locale language;

  bool isDarkMode;

  String currency;

  _Preferences({Locale? language, bool? isDarkMode, String? currency})
      : language = language ?? LanguageProvider.defaultLocale,
        isDarkMode = isDarkMode ?? ThemeProvider.defaultTheme,
        currency = currency ?? CurrencyProvider.defaultCurrency;
}
