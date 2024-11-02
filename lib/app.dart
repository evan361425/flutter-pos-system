import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/constants/constant.dart';

import 'constants/app_themes.dart';
import 'routes.dart';
import 'settings/language_setting.dart';
import 'settings/settings_provider.dart';
import 'settings/theme_setting.dart';
import 'translator.dart';

class App extends StatelessWidget {
  static final routeObserver = RouteObserver<ModalRoute<void>>();

  static final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  static ValueNotifier<RoutingConfig>? routingConfig;

  // singleton be avoid recreate after hot reload.
  static RouterConfig<Object>? router;

  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final routes = Routes.getDesiredRoute(MediaQuery.sizeOf(context).width);
    routingConfig ??= ValueNotifier(routes);
    routingConfig!.value = routes;
    router ??= GoRouter.routingConfig(
      initialLocation: Routes.initLocation,
      routingConfig: routingConfig!,
      navigatorKey: Routes.rootNavigatorKey,
      // By default, go_router comes with default error screens for both
      // MaterialApp and CupertinoApp as well as a default error screen in
      // the case that none is used.
      // onException: (context, state, route) => context.go('/pos'),
      debugLogDiagnostics: kDebugMode,
      observers: [
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
        routeObserver,
      ],
    );

    // Glue the SettingsController to the MaterialApp.
    //
    // The AnimatedBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    return AnimatedBuilder(
      animation: SettingsProvider.instance,
      builder: (context, child) {
        return MaterialApp.router(
          routerConfig: router!,
          scaffoldMessengerKey: scaffoldMessengerKey,
          onGenerateTitle: (context) {
            // According to document, it should followed when system changed language.
            // https://docs.flutter.dev/development/accessibility-and-localization/internationalization#specifying-the-apps-supportedlocales-parameter
            final localizations = AppLocalizations.of(context)!;

            setAppLocalizations(localizations);
            // if no setup language, it will use system language. We try to
            // catch system language here. Only first time calling will take
            // effect.
            LanguageSetting.instance.systemLanguage = S.localeName;

            FlutterNativeSplash.remove();

            return localizations.appTitle;
          },
          debugShowCheckedModeBanner: !isProd,

          // Provide the generated AppLocalizations to the MaterialApp. This
          // allows descendant Widgets to display the correct translations
          // depending on the user's locale.
          locale: LanguageSetting.instance.value?.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,

          // Define a light and dark color theme. Then, read the user's
          // preferred ThemeMode (light, dark, or system default) from the
          // SettingsController to display the correct theme.
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: ThemeSetting.instance.value,
        );
      },
    );
  }
}
