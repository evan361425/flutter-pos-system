import 'dart:async';
import 'package:flutter/material.dart';
import 'package:possystem/localizations.dart';
import 'package:possystem/models/user_model.dart';
import 'package:possystem/routes.dart';
import 'package:provider/provider.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    var user = context.watch<UserModel>();

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              Local.of(context).tf('welcome', [user.name]),
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
    );
  }

  dynamic startTimer() {
    var duration = Duration(milliseconds: 1000);
    return Timer(duration, redirect);
  }

  dynamic redirect() async {
    await Navigator?.of(context)?.pushReplacementNamed(Routes.menu);
  }
}
