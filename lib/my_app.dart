import 'package:flutter/material.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/home_container.dart';
import 'package:possystem/constants/app_themes.dart';
import 'package:possystem/providers/language_provider.dart';
import 'package:possystem/providers/theme_provider.dart';
import 'package:possystem/ui/splash/logo_splash.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, Object>>(
        future: _waitPreferences(context),
        builder: (context, values) {
          var darkMode = false;
          var locale = LanguageProvider.defaultLocale;
          final data = values.data;
          if (data != null) {
            darkMode = data['theme'];
            locale = data['language'];
          }

          return MaterialApp(
            title: 'POS System',
            routes: Routes.routes,
            debugShowCheckedModeBanner: false,
            // === language setting ===
            locale: locale,
            supportedLocales: LanguageProvider.supports,
            localizationsDelegates: LanguageProvider.delegates,
            localeResolutionCallback: LanguageProvider.localResolutionCallback,
            // === theme setting ===
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
            // === home widget ===
            home: values.hasData ? HomeContainer() : LogoSplash(),
          );
        });
  }

  Future<Map<String, Object>> _waitPreferences(BuildContext context) async {
    final theme = context.watch<ThemeProvider>();
    final language = context.watch<LanguageProvider>();

    return {
      'theme': await theme.getDarkMode(),
      'language': await language.getLocale(),
    };
  }
}
