import 'package:flutter/material.dart';
import 'package:possystem/components/style/card_tile.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/providers/language_provider.dart';
import 'package:possystem/providers/theme_provider.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/setting/widgets/language_modal.dart';
import 'package:possystem/ui/setting/widgets/theme_modal.dart';
import 'package:provider/provider.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = context.read<ThemeProvider>();
    final language = context.read<LanguageProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(tt('setting')),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(KIcons.back),
        ),
      ),
      body: ListView(
        children: <Widget>[
          CardTile(
            title: Text(tt('setting.theme.title')),
            subtitle:
                Text(tt('setting.theme.${ThemeModal.ThemeCode[theme.mode]}')),
            trailing: Icon(Icons.arrow_forward_ios_sharp),
            onTap: () => Navigator.of(context).pushNamed(Routes.settingTheme),
          ),
          CardTile(
            title: Text(tt('setting.language.title')),
            subtitle:
                Text(LanguageModal.LanguageName[language.locale.toString()]!),
            trailing: Icon(Icons.arrow_forward_ios_sharp),
            onTap: () => Navigator.of(context)
                .pushNamed(Routes.settingLanguage)
                .then((isChanged) {
              if (isChanged == true) {
                setState(() {});
              }
            }),
          ),
        ],
      ),
    );
  }
}
