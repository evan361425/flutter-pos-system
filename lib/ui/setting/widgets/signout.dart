import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:possystem/localizations.dart';
import 'package:possystem/routes.dart';
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
    showPlatformDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: Text(Local.of(context).t('alert_title')),
        content: Text(Local.of(context).t('setting.logout.alert')),
        actions: <Widget>[
          PlatformDialogAction(
            child: PlatformText(Local.of(context).t('cancel')),
            onPressed: () => Navigator.pop(context),
          ),
          PlatformDialogAction(
            child: PlatformText(Local.of(context).t('confirm')),
            onPressed: () {
              final authProvider = context.read<Authentication>();

              authProvider.signOut();

              Navigator.pop(context);
              Navigator.of(context).pushNamedAndRemoveUntil(
                Routes.login,
                ModalRoute.withName(Routes.login),
              );
            },
          )
        ],
      ),
    );
  }
}
