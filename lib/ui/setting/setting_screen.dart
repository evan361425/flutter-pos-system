import 'package:flutter/material.dart';
import 'package:possystem/components/card_tile.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/localizations.dart';
import 'package:possystem/providers/language_provider.dart';
import 'package:possystem/providers/theme_provider.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/setting/widgets/language_modal.dart';
import 'package:possystem/ui/setting/widgets/theme_modal.dart';
import 'package:provider/provider.dart';

class SettingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final language = context.watch<LanguageProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(Local.of(context)!.t('setting')),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(KIcons.back),
        ),
      ),
      body: ListView(
        children: <Widget>[
          CardTile(
            title: Text(Local.of(context)!.t('setting.theme.title')),
            subtitle: Text(ThemeModal.ThemeName[theme.mode]!),
            trailing: Icon(Icons.arrow_forward_ios_sharp),
            onTap: () async {
              final selected =
                  await Navigator.of(context).pushNamed(Routes.settingTheme);

              if (selected != null && selected != theme.mode) {
                await theme.setMode(selected as ThemeMode);
              }
            },
          ),
          CardTile(
            title: Text(Local.of(context)!.t('setting.language.title')),
            subtitle:
                Text(LanguageModal.LanguageName[language.locale.toString()]!),
            trailing: Icon(Icons.arrow_forward_ios_sharp),
            onTap: () async {
              final selected =
                  await Navigator.of(context).pushNamed(Routes.settingLanguage);

              if (selected != null && selected != language.locale) {
                await language.setLocale(selected as Locale);
              }
            },
          ),
        ],
      ),
    );
  }
}
