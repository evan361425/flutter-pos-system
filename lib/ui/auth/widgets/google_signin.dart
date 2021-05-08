import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:possystem/components/circular_loading.dart';
import 'package:possystem/localizations.dart';
import 'package:possystem/providers/theme_provider.dart';
import 'package:possystem/services/authentication.dart';
import 'package:possystem/services/sign_in_method/sign_in_by_google.dart';
import 'package:provider/provider.dart';

class GoogleSignIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<Authentication>();
    final themeProvider = context.read<ThemeProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          authProvider.status == AuthStatus.Authenticating
              ? CircularLoading()
              : SignInButton(
                  themeProvider.darkMode ? Buttons.GoogleDark : Buttons.Google,
                  onPressed: () => _confirm(context),
                ),
          authProvider.status == AuthStatus.Failed
              ? Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Center(
                    child: Text(
                      Local.of(context).t('auth.reject'),
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
    final authProvider = context.read<Authentication>();
    FocusScope.of(context).unfocus(); //to hide the keyboard - if any

    var user = await authProvider.signIn(context, SignInByGoogle());

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(Local.of(context).t('auth.reject')),
        backgroundColor: Theme.of(context).snackBarTheme.backgroundColor,
      ));
    }
  }
}
