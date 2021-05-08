import 'package:flutter/material.dart';
import 'package:possystem/components/card_tile.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/localizations.dart';
import 'package:possystem/providers/language_provider.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/setting/widgets/theme.dart';
import 'package:provider/provider.dart';

class SettingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>();
    final locale = Local.of(context).t(
      'setting.language.${language.locale.toString()}',
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(Local.of(context).t('setting')),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(KIcons.back),
        ),
      ),
      body: ListView(
        children: <Widget>[
          CardTile(
            title: Text(Local.of(context).t('setting.theme.title')),
            trailing: ThemeSwitch(),
          ),
          CardTile(
            title: Text(Local.of(context).t('setting.language.title')),
            subtitle: Text(locale),
            trailing: Icon(Icons.arrow_forward_ios_sharp),
            onTap: () async {
              final selected = await Navigator.of(context).pushNamed(
                Routes.settingLanguage,
              );

              print(selected);

              if (selected != null && selected != language.locale) {
                language.locale = selected;
              }
            },
          ),
        ],
      ),
    );
  }
}
