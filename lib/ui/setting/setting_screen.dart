import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:possystem/app_localizations.dart';
import 'package:possystem/providers/auth_provider.dart';
import 'package:possystem/providers/theme_provider.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/setting/setting_language_actions.dart';
import 'package:provider/provider.dart';

class SettingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        ListTile(
          title: Text(Trans.of(context).t('setting.theme.title')),
          subtitle: Text(Trans.of(context).t('setting.theme.subtitle')),
          trailing: Switch(
            activeColor: Theme.of(context).appBarTheme.color,
            activeTrackColor: Theme.of(context).textTheme.headline6.color,
            value: Provider.of<ThemeProvider>(context).isDarkModeOn,
            onChanged: (booleanValue) {
              Provider.of<ThemeProvider>(context, listen: false)
                  .updateTheme(booleanValue);
            },
          ),
        ),
        ListTile(
          title: Text(Trans.of(context).t('setting.language.title')),
          subtitle:
              Text(Trans.of(context).t('setting.language.subtitle')),
          trailing: SettingLanguageActions(),
        ),
        ListTile(
          title: Text(Trans.of(context).t('setting.logout.title')),
          subtitle:
              Text(Trans.of(context).t('setting.logout.subtitle')),
          trailing: RaisedButton(
            onPressed: () {
              _confirmSignOut(context);
            },
            child: Text(
              Trans.of(context).t('setting.logout.button'),
            ),
          ),
        )
      ],
    );
  }

  void _confirmSignOut(BuildContext context) {
    showPlatformDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: Text(Trans.of(context).t('alert_title')),
        content: Text(Trans.of(context).t('setting.logout.alert')),
        actions: <Widget>[
          PlatformDialogAction(
            child: PlatformText(Trans.of(context).t('cancel')),
            onPressed: () => Navigator.pop(context),
          ),
          PlatformDialogAction(
            child: PlatformText(Trans.of(context).t('confirm')),
            onPressed: () {
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);

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
