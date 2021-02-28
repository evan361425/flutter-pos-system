import 'package:flutter/material.dart';
import 'package:possystem/localizations.dart';
import 'package:possystem/services/authentication.dart';
import 'package:provider/provider.dart';

class SignoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: RaisedButton(
        onPressed: () => _confirm(context),
        child: Text(Local.of(context).t('setting.logout.button')),
      ),
    );
  }

  void _confirm(BuildContext context) {
    AlertDialog(
      title: Text(Local.of(context).t('alert_title')),
      content: Text(Local.of(context).t('setting.logout.alert')),
      actions: <Widget>[
        FlatButton(
          child: Text(Local.of(context).t('confirm')),
          onPressed: () {
            final authProvider = context.read<Authentication>();

            authProvider.signOut();

            Navigator.pop(context);
            // TODO: go to other page
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/login',
              ModalRoute.withName('/login'),
            );
          },
        ),
        RaisedButton(
          child: Text(Local.of(context).t('cancel')),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
