import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (_, ThemeProvider theme, LanguageProvider language, __) {
        // get data from user
        return UserDependencies(
          databaseBuilder: databaseBuilder,
          builder: (_, AsyncSnapshot<UserModel> user) {
            return _buildApp(theme, language, user);
          },
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
        ? Material(child: Center(child: CircularProgressIndicator()))
        : user.hasData
            ? HomeContainer()
            : SignInScreen();

    return MaterialApp(
      title: 'POS System',
      routes: Routes.routes,
      debugShowCheckedModeBanner: false,
      // === language setting ===
      locale: language.initLocale(),
      supportedLocales: LanguageProvider.supports,
      localizationsDelegates: LanguageProvider.delegates,
      localeResolutionCallback: LanguageProvider.localResolutionCallback,
      // === theme setting ===
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: theme.isDarkModeOn ? ThemeMode.dark : ThemeMode.light,
      // === home widget ===
      home: home,
    );
  }
}
