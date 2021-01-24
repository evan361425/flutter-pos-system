import 'package:flutter/material.dart';
import 'package:possystem/app_localizations.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:possystem/providers/auth_provider.dart';
import 'package:possystem/providers/theme_provider.dart';
import 'package:provider/provider.dart';

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
          _buildBackground(),
          _buildBody(),
          _buildName(),
        ],
      ),
    );
  }

  void _googleSignIn(AuthProvider authProvider) async {
    FocusScope.of(context).unfocus(); //to hide the keyboard - if any

    var user = await authProvider.signInByGoogle();

    if (user == null) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context).t('sign_in.reject')),
      ));
    }
  }

  Widget _buildBody() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildLogo(),
                _buildForm(),
              ]),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Image.asset(
        'assets/logo.png',
        width: 128,
        height: 128,
      ),
    );
  }

  Widget _buildForm() {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          authProvider.status == Status.Authenticating
              ? themeProvider.component(context, 'spinner')
              : SignInButton(
                  themeProvider.isDarkModeOn
                      ? Buttons.GoogleDark
                      : Buttons.Google,
                  onPressed: () async {
                    await _googleSignIn(authProvider);
                  },
                ),
          authProvider.status == Status.Failed
              ? Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: themeProvider.text(context, 'sign_in.reject'),
                )
              : Center(
                  child: null,
                ),
        ],
      ),
    );
  }

  Widget _buildName() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context).t('app'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10),
            )
          ],
        )
      ],
    );
  }

  Widget _buildBackground() {
    return ClipPath(
      clipper: SignInCustomClipper(),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.5,
        color: Theme.of(context).iconTheme.color,
      ),
    );
  }
}

class SignInCustomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height);

    var firstEndPoint = Offset(size.width / 2, size.height - 95);
    var firstControlPoint = Offset(size.width / 6, size.height * 0.45);

    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondEndPoint = Offset(size.width, size.height / 2 - 50);
    var secondControlPoint = Offset(size.width, size.height + 15);

    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
