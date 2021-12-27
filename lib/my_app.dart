import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'constants/app_themes.dart';
import 'routes.dart';
import 'settings/language_setting.dart';
import 'settings/settings_provider.dart';
import 'settings/theme_setting.dart';
import 'translator.dart';

class MyApp extends StatelessWidget {
  static final analytics = FirebaseAnalytics();

  static final routeObserver = RouteObserver<ModalRoute<void>>();

  final Widget child;

  final SettingsProvider settings;

  const MyApp({
    Key? key,
    required this.settings,
    required this.child,
  }) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Glue the SettingsController to the MaterialApp.
    //
    // The AnimatedBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    return AnimatedBuilder(
        animation: settings,
        builder: (_, __) {
          return MaterialApp(
            onGenerateTitle: (context) {
              final localizations = AppLocalizations.of(context)!;
              // TODO check if monitor device language changing
              // final language = settings.getSetting<LanguageSetting>();
              // final locale = language.parseLanguage(localizations.localeName)!;

              // if user change language by system
              // language.update(locale);

              S = localizations;

              return localizations.appTitle;
            },
            routes: Routes.routes,
            debugShowCheckedModeBanner: false,
            navigatorObservers: [
              FirebaseAnalyticsObserver(analytics: analytics),
              routeObserver,
            ],

            // Provide the generated AppLocalizations to the MaterialApp. This
            // allows descendant Widgets to display the correct translations
            // depending on the user's locale.
            locale: settings.getSetting<LanguageSetting>().value,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,

            // Define a light and dark color theme. Then, read the user's
            // preferred ThemeMode (light, dark, or system default) from the
            // SettingsController to display the correct theme.
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: settings.getSetting<ThemeSetting>().value,

            home: child,
          );
        });
  }
}
