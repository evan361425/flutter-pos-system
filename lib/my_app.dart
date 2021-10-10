import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'constants/app_themes.dart';
import 'providers/currency_provider.dart';
import 'providers/language_provider.dart';
import 'providers/theme_provider.dart';
import 'routes.dart';

class MyApp extends StatelessWidget {
  static final analytics = FirebaseAnalytics();

  static final routeObserver = RouteObserver<ModalRoute<void>>();

  static bool _initialized = false;

  final Widget child;

  const MyApp(this.child);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final language = context.watch<LanguageProvider>();
    final currency = context.watch<CurrencyProvider>();

    if (!_initialized) {
      theme.initialize();
      language.initialize();
      currency.initialize();
      _initialized = true;
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
      locale: language.locale,
      supportedLocales: LanguageProvider.supports,
      localizationsDelegates: LanguageProvider.delegates,
      localeListResolutionCallback: language.localeListResolutionCallback,
      // === theme setting ===
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: theme.mode,
      // === home widget ===
      home: child,
    );
  }
}
