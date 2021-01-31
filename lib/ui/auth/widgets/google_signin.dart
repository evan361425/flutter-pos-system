import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:possystem/app_localizations.dart';
import 'package:possystem/providers/auth_provider.dart';
import 'package:possystem/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class GoogleSignIn extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey;

  GoogleSignIn(this._scaffoldKey);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          authProvider.status == Status.Authenticating
              ? Center(child: CircularProgressIndicator())
              : SignInButton(
                  themeProvider.isDarkModeOn
                      ? Buttons.GoogleDark
                      : Buttons.Google,
                  onPressed: () async {
                    await _confirm(context);
                  },
                ),
          authProvider.status == Status.Failed
              ? Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Center(
                    child: Text(
                      Trans.of(context).t('auth.reject'),
                      style: Theme.of(context).textTheme.button,
                    ),
                  ),
                )
              : Center(child: null)
        ],
      ),
    );
  }

  void _confirm(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context);
    FocusScope.of(context).unfocus(); //to hide the keyboard - if any

    var user = await authProvider.signInByGoogle(context);

    if (user == null) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(Trans.of(context).t('auth.reject')),
        backgroundColor: Theme.of(context).snackBarTheme.backgroundColor,
      ));
    }
  }
}
