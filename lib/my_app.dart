import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:possystem/components/circular_loading.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/home_container.dart';
import 'package:possystem/ui/splash/logo_splash.dart';
import 'package:possystem/user_dependencies.dart';
import 'package:possystem/constants/app_themes.dart';
import 'package:possystem/models/user_model.dart';
import 'package:possystem/providers/language_provider.dart';
import 'package:possystem/providers/theme_provider.dart';
import 'package:possystem/services/database.dart';
import 'package:possystem/ui/auth/sign_in_screen.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  // Expose builders for 3rd party services at the root of the widget tree
  // This is useful when mocking services while testing
  final Database Function(String uid) databaseBuilder;

  const MyApp({Key key, this.databaseBuilder}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (_, AsyncSnapshot<FirebaseApp> firebase) {
        if (firebase.hasError) {
          print('firebase has error...');
          // TODO: error handler
          return Text('QQ');
        }

        if (firebase.connectionState == ConnectionState.done) {
          return _buildProviders();
        }

        return LogoSplash();
      },
    );
  }

  Widget _buildProviders() {
    /// Why use Consumer, not Provider.of?
    /// https://stackoverflow.com/questions/58774301/when-to-use-provider-ofx-vs-consumerx-in-flutter
    return UserDependencies(
      databaseBuilder: databaseBuilder,
      builder: (BuildContext context, AsyncSnapshot<UserModel> user) {
        return _buildApp(
          context.watch<ThemeProvider>(),
          context.watch<LanguageProvider>(),
          user,
        );
      },
    );
  }

  Widget _buildApp(
    ThemeProvider theme,
    LanguageProvider language,
    AsyncSnapshot<UserModel> user,
  ) {
    // TODO: handle more connection state
    final home = user.connectionState == ConnectionState.waiting
        ? Material(child: CircularLoading())
        : user.hasData
            ? HomeContainer()
            : SignInScreen();

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
      home: home,
    );
  }
}
