import 'package:flutter/material.dart';
import 'package:possystem/components/scaffold/item_list_scaffold.dart';
import 'package:possystem/components/style/card_tile.dart';
import 'package:possystem/components/style/feature_switch.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/providers/feature_provider.dart';
import 'package:possystem/providers/language_provider.dart';
import 'package:possystem/providers/theme_provider.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';

const _OUTLOOK_ORDER = {
  OutlookOrder.sliding_panel: '酷炫面板',
  OutlookOrder.classic: '經典模式',
};

const _THEME_CODE = <ThemeMode, String>{
  ThemeMode.system: 'system',
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
};

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = context.read<ThemeProvider>();
    final language = context.read<LanguageProvider>();

    final selectedLanguage = LanguageProvider.supports.indexOf(language.locale);
    final selectedTheme = theme.mode.index;
    final themeList = ThemeMode.values
        .map<String>((e) => tt('setting.theme.${_THEME_CODE[e]}'))
        .toList();

    final outlookOrder = FeatureProvider.instance.outlookOrder;

    return Scaffold(
      appBar: AppBar(
        title: Text(tt('home.setting')),
        leading: PopButton(),
      ),
      body: ListView(
        children: <Widget>[
          CardTile(
            key: Key('setting.theme'),
            title: Text(tt('setting.theme.title')),
            subtitle: Text(tt('setting.theme.${_THEME_CODE[theme.mode]}')),
            trailing: Icon(Icons.arrow_forward_ios_sharp),
            onTap: () => _navigateItemList(
              (index) => theme.setMode(ThemeMode.values[index]),
              title: tt('setting.theme.title'),
              items: themeList,
              selected: selectedTheme,
            ),
          ),
          CardTile(
            key: Key('setting.language'),
            title: Text(tt('setting.language.title')),
            subtitle: Text(LanguageProvider.supportNames[selectedLanguage]),
            trailing: Icon(Icons.arrow_forward_ios_sharp),
            onTap: () => _navigateItemList(
              (index) => language.setLocale(LanguageProvider.supports[index]),
              title: tt('setting.language.title'),
              items: LanguageProvider.supportNames,
              selected: selectedLanguage,
            ),
          ),
          const SizedBox(height: kSpacing2),
          CardTile(
            key: Key('setting.outlook_order'),
            title: Text('點餐的外觀'),
            subtitle: Text(_OUTLOOK_ORDER[outlookOrder]!),
            trailing: Icon(Icons.arrow_forward_ios_sharp),
            onTap: () => _navigateItemList(
              (index) => FeatureProvider.instance.setOutlookOrder(index),
              title: '點餐的外觀',
              items:
                  OutlookOrder.values.map((e) => _OUTLOOK_ORDER[e]!).toList(),
              selected: outlookOrder.index,
            ),
          ),
          CardTile(
            title: Text('點餐時不關閉螢幕'),
            trailing: FeatureSwitch(
              key: Key('setting.feature.awake_ordering'),
              value: FeatureProvider.instance.awakeOrdering,
              onChanged: (value) =>
                  FeatureProvider.instance.setAwakeOrdering(value),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateItemList(
    Future<void> Function(int) onChanged, {
    required String title,
    required List<String> items,
    required int selected,
  }) async {
    final newSelected = await Navigator.of(context).push<int>(
      MaterialPageRoute(
          builder: (_) => ItemListScaffold(
                title: title,
                items: items,
                selected: selected,
              )),
    );

    if (newSelected != null) {
      await onChanged(newSelected);
      setState(() {});
    }
  }
}
