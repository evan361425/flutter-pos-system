import 'package:flutter/material.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/home_container.dart';
import 'package:possystem/constants/app_themes.dart';
import 'package:possystem/providers/language_provider.dart';
import 'package:possystem/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final language = context.watch<LanguageProvider>();

    return MaterialApp(
      title: 'POS System',
      routes: Routes.routes,
      debugShowCheckedModeBanner: false,
      // === language setting ===
      locale: language.locale,
      supportedLocales: LanguageProvider.supports,
      localizationsDelegates: LanguageProvider.delegates,
      localeResolutionCallback: LanguageProvider.localResolutionCallback,
      // === theme setting ===
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: theme.darkMode ? ThemeMode.dark : ThemeMode.light,
      // === home widget ===
      home: HomeContainer(),
    );
  }
}
