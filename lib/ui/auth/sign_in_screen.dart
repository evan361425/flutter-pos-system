import 'package:flutter/material.dart';
import 'package:possystem/ui/auth/widgets/background.dart';
import 'package:possystem/ui/auth/widgets/body.dart';
import 'package:possystem/ui/auth/widgets/bottom_small_text.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: <Widget>[
          Background(),
          Body(),
          ButtomSmallText(),
        ],
      ),
    );
  }
}
