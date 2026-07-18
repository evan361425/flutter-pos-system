import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/l10n/gen/app_localizations.dart';

import 'constants/app_themes.dart';
import 'routes.dart';
import 'services/staff/employee_manager_service.dart';
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

  const App({super.key}); // coverage:ignore-line

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
      // Re-run redirects when staff login / logout changes.
      refreshListenable: EmployeeManagerService.instance,
      debugLogDiagnostics: kDebugMode,
      observers: [
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
        routeObserver,
      ],
    );

    // Split the AnimatedBuilder into granular listeners to avoid full app rebuilds
    return _AppRoot();
  }
}

class _AppRoot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Theme and themeMode only need ThemeSetting listener
    final theme = AnimatedBuilder(
      animation: ThemeSetting.instance,
      builder: (context, child) {
        return MaterialApp.router(
          routerConfig: App.router!,
          scaffoldMessengerKey: App.scaffoldMessengerKey,
          onGenerateTitle: (context) {
            final localizations = AppLocalizations.of(context)!;
            setAppLocalizations(localizations);
            LanguageSetting.instance.systemLanguage = S.localeName;
            FlutterNativeSplash.remove();
            return localizations.appTitle;
          },
          debugShowCheckedModeBanner: !isProd,
          locale: LanguageSetting.instance.value?.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: ThemeSetting.instance.value,
        );
      },
    );

    // Locale only needs LanguageSetting listener
    return AnimatedBuilder(
      animation: LanguageSetting.instance,
      builder: (context, child) {
        return theme;
      },
    );
  }
}
