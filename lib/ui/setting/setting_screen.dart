import 'package:flutter/material.dart';
import 'package:possystem/components/style/card_tile.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/providers/feature_provider.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/providers/language_provider.dart';
import 'package:possystem/providers/theme_provider.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/components/style/feature_switch.dart';
import 'package:possystem/ui/setting/widgets/language_modal.dart';
import 'package:possystem/ui/setting/widgets/theme_modal.dart';
import 'package:provider/provider.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen();

  @override
  Widget build(BuildContext context) {
    final theme = context.read<ThemeProvider>();
    final language = context.read<LanguageProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(tt('home.setting')),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(KIcons.back),
        ),
      ),
      body: ListView(
        children: <Widget>[
          _GroupTitle(title: '外觀', isFirst: true),
          CardTile(
            title: Text(tt('setting.theme.title')),
            subtitle:
                Text(tt('setting.theme.${ThemeModal.ThemeCode[theme.mode]}')),
            trailing: Icon(Icons.arrow_forward_ios_sharp),
            onTap: () => Navigator.of(context).pushNamed(Routes.settingTheme),
          ),
          CardTile(
            title: Text(tt('setting.language.title')),
            subtitle: Text(LanguageModal.getLanguageName(language.locale)),
            trailing: Icon(Icons.arrow_forward_ios_sharp),
            onTap: () =>
                Navigator.of(context).pushNamed(Routes.settingLanguage),
          ),
          _GroupTitle(title: '操作'),
          CardTile(
            title: Text('點餐時不關閉螢幕'),
            trailing: FeatureSwitch(
              key: Key('setting.feature.awate_ordering'),
              value: FeatureProvider.instance.awakeOrdering,
              onChanged: (value) =>
                  FeatureProvider.instance.awakeOrdering = value,
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupTitle extends StatelessWidget {
  final bool isFirst;

  final String title;

  const _GroupTitle({
    Key? key,
    required this.title,
    this.isFirst = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: isFirst
          ? const EdgeInsets.all(kSpacing1)
          : const EdgeInsets.fromLTRB(
              kSpacing1, kSpacing3, kSpacing1, kSpacing1),
      child: Text(title),
    );
  }
}
