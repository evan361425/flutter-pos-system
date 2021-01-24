import 'dart:async';
import 'package:flutter/material.dart';
import 'package:possystem/app_localizations.dart';
import 'package:possystem/models/user_model.dart';
import 'package:possystem/providers/auth_provider.dart';
import 'package:possystem/routes.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    var authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: StreamBuilder(
                stream: authProvider.user,
                builder: (context, snapshot) {
                  final UserModel user = snapshot.data;
                  if (user == null) {
                    return Center(child: null);
                  }

                  return Text(
                    AppLocalizations.of(context).tf('welcome', [user.name]),
                    style: TextStyle(
                      fontSize: Theme.of(context).textTheme.headline.fontSize,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  dynamic startTimer() {
    var duration = Duration(milliseconds: 3000);
    return Timer(duration, redirect);
  }

  dynamic redirect() async {
    await Navigator.of(context).pushReplacementNamed(Routes.home);
  }
}
