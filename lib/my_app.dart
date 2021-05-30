import 'package:flutter/material.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/services/database.dart';
import 'package:possystem/services/storage.dart';
import 'package:possystem/ui/home_container.dart';
import 'package:possystem/constants/app_themes.dart';
import 'package:possystem/providers/language_provider.dart';
import 'package:possystem/providers/theme_provider.dart';
import 'package:possystem/ui/splash/logo_splash.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: _waitPreferences(context),
        initialData: false,
        builder: (context, snapshot) {
          final prepared = snapshot.data!;
          final theme = context.read<ThemeProvider>();
          final language = context.read<LanguageProvider>();
          final useDark =
              prepared ? theme.darkMode : ThemeProvider.defaultTheme;

          return MaterialApp(
            title: 'POS System',
            routes: Routes.routes,
            debugShowCheckedModeBanner: false,
            // === language setting ===
            locale: prepared ? language.locale : LanguageProvider.defaultLocale,
            supportedLocales: LanguageProvider.supports,
            localizationsDelegates: LanguageProvider.delegates,
            localeResolutionCallback: LanguageProvider.localResolutionCallback,
            // === theme setting ===
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: useDark ? ThemeMode.dark : ThemeMode.light,
            // === home widget ===
            home: prepared ? HomeContainer() : LogoSplash(),
          );
        });
  }

  Future<bool> _waitPreferences(BuildContext context) async {
    final themeProvider = context.watch<ThemeProvider>();
    final languageProvider = context.watch<LanguageProvider>();

    await Database.instance.initialize();
    await Storage.instance.initialize();
    await themeProvider.initialize();
    await languageProvider.initialize();

    return true;
  }
}
