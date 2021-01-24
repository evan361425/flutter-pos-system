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
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).t('setting.title')),
      ),
      body: _buildLayoutSection(context),
    );
  }

  Widget _buildLayoutSection(BuildContext context) {
    return ListView(
      children: <Widget>[
        ListTile(
          title: Text(AppLocalizations.of(context).t('setting.theme')),
          subtitle: Text(AppLocalizations.of(context).t('setting.theme_title')),
          trailing: Switch(
            activeColor: Theme.of(context).appBarTheme.color,
            activeTrackColor: Theme.of(context).textTheme.title.color,
            value: Provider.of<ThemeProvider>(context).isDarkModeOn,
            onChanged: (booleanValue) {
              Provider.of<ThemeProvider>(context, listen: false)
                  .updateTheme(booleanValue);
            },
          ),
        ),
        ListTile(
          title: Text(AppLocalizations.of(context).t('setting.language')),
          subtitle:
              Text(AppLocalizations.of(context).t('setting.language_title')),
          trailing: SettingLanguageActions(),
        ),
        ListTile(
          title: Text(AppLocalizations.of(context).t('setting.logout')),
          subtitle:
              Text(AppLocalizations.of(context).t('setting.logout_title')),
          trailing: RaisedButton(
              onPressed: () {
                _confirmSignOut(context);
              },
              child: Text(
                  AppLocalizations.of(context).t('setting.logout_button'))),
        )
      ],
    );
  }

  void _confirmSignOut(BuildContext context) {
    showPlatformDialog(
        context: context,
        builder: (_) => PlatformAlertDialog(
              title: Text(AppLocalizations.of(context).t('alert_title')),
              content:
                  Text(AppLocalizations.of(context).t('setting.logout_alert')),
              actions: <Widget>[
                PlatformDialogAction(
                  child: PlatformText(AppLocalizations.of(context).t('cancel')),
                  onPressed: () => Navigator.pop(context),
                ),
                PlatformDialogAction(
                  child:
                      PlatformText(AppLocalizations.of(context).t('confirm')),
                  onPressed: () {
                    final authProvider =
                        Provider.of<AuthProvider>(context, listen: false);

                    authProvider.signOut();

                    Navigator.pop(context);
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        Routes.login, ModalRoute.withName(Routes.login));
                  },
                )
              ],
            ));
  }
}
