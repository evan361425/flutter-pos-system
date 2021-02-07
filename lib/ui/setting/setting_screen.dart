import 'package:flutter/material.dart';
import 'package:possystem/localizations.dart';
import 'package:possystem/ui/setting/widgets/language.dart';
import 'package:possystem/ui/setting/widgets/signout.dart';
import 'package:possystem/ui/setting/widgets/theme.dart';

class SettingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Local.of(context).t('setting')),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back_ios),
        ),
      ),
      body: ListView(
        children: <Widget>[
          _buildCard(
            Local.of(context).t('setting.theme.title'),
            Local.of(context).t('setting.theme.subtitle'),
            ThemeSwitch(),
          ),
          _buildCard(
            Local.of(context).t('setting.language.title'),
            Local.of(context).t('setting.language.subtitle'),
            LanguagePopupMenu(),
          ),
          _buildCard(
            Local.of(context).t('setting.logout.title'),
            Local.of(context).t('setting.logout.subtitle'),
            SignoutButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, String subtitle, Widget trailing) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: trailing,
      ),
    );
  }
}
