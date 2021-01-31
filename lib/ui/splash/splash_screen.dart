import 'dart:async';
import 'package:flutter/material.dart';
import 'package:possystem/app_localizations.dart';
import 'package:possystem/models/user_model.dart';
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
    var user = Provider.of<UserModel>(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Text(
                Trans.of(context).tf('welcome', [user.name]),
                style: Theme.of(context).textTheme.headline4,
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
    await Navigator.of(context).pushReplacementNamed(Routes.backend);
  }
}
