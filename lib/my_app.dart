import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:possystem/auth_widget_builder.dart';
import 'package:possystem/constants/app_themes.dart';
import 'package:possystem/models/user_model.dart';
import 'package:possystem/providers/auth_provider.dart';
import 'package:possystem/providers/language_provider.dart';
import 'package:possystem/providers/theme_provider.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/services/firestore_database.dart';
import 'package:possystem/ui/auth/sign_in_screen.dart';
import 'package:possystem/ui/home/home.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key key, this.databaseBuilder}) : super(key: key);

  // Expose builders for 3rd party services at the root of the widget tree
  // This is useful when mocking services while testing
  final FirestoreDatabase Function(BuildContext context, String uid)
      databaseBuilder;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (_, AsyncSnapshot<FirebaseApp> firebase) {
        if (firebase.hasError) {
          print('firebase has error...');
          return Text('QQ');
        }

        if (firebase.connectionState == ConnectionState.done) {
          return _buildProviders();
        }

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', width: 128, height: 128),
            ],
          )
        );
      },
    );
  }

  Widget _buildProviders() {
    return Consumer<ThemeProvider>(
      builder: (_, ThemeProvider theme, __) {
        return Consumer<LanguageProvider>(
          builder: (_, LanguageProvider language, __) {
            return AuthWidgetBuilder(
              databaseBuilder: databaseBuilder,
              builder: (_, AsyncSnapshot<UserModel> user) {
                return _buildApp(theme, language, user);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildApp(ThemeProvider theme, LanguageProvider language,
      AsyncSnapshot<UserModel> user) {
    return MaterialApp(
      title: 'POS System',
      routes: Routes.routes,
      debugShowCheckedModeBanner: false,
      locale: language.appLocale,
      supportedLocales: LanguageProvider.supports,
      localizationsDelegates: LanguageProvider.delegates,
      //return a locale which will be used by the app
      localeResolutionCallback: LanguageProvider.localResolutionCallback,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: theme.isDarkModeOn ? ThemeMode.dark : ThemeMode.light,
      home: Consumer<AuthProvider>(
        builder: (_, auth, __) {
          if (user.connectionState == ConnectionState.active) {
            return user.hasData ? HomeScreen() : SignInScreen();
          }

          return Material(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
