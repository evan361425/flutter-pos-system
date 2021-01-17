import 'dart:async';
import 'dart:convert' show json;

import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
    'profile',
  ],
);

class SignIn extends StatefulWidget {
  @override
  State createState() => SignInState();
}

class SignInState extends State<SignIn> {
  String _status;

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      if (account != null) {
        Navigator.pushReplacementNamed(context, '/menu/design');
      }
      _setStatus('馬上登入/註冊吧！😘');
    });
    _googleSignIn.signInSilently();
  }

  void _setStatus(String status) {
    setState(() {
      _status = status;
    });
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
      _setStatus(error.toString());
    }
  }

  Widget _buildBody() {
    return Center(
      child: ListView(
        children: <Widget>[
          _buildCard(),
          SizedBox(height: 20),
          Text(
            'POS System',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildCard() {
    return Card(
      child: Column(
        children: <Widget>[
          _buildCardImage(),
          SizedBox(height: 20),
          _buildCardSignIn(),
        ],
      ),
      // elevation: 20,
      shape: BeveledRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(150),
        ),
      ),
    );
  }

  Widget _buildCardImage() {
    return Container(
      padding: EdgeInsets.fromLTRB(10.0, 50.0, 10.0, 50.0),
      child: FittedBox(
        child: Image.asset('assets/logo.png'),
        fit: BoxFit.fill,
      ),
    );
  }

  Widget _buildCardSignIn() {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SignInButton(
            Buttons.Google,
            onPressed: _handleSignIn,
          ),
          Text('$_status'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: _buildBody(),
      )
    );
  }
}