import 'package:flutter/material.dart';
import 'package:possystem/components/scaffold/item_list_scaffold.dart';
import 'package:possystem/components/style/card_tile.dart';
import 'package:possystem/components/style/feature_switch.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/settings/language_setting.dart';
import 'package:possystem/settings/order_awakening_setting.dart';
import 'package:possystem/settings/order_outlook_setting.dart';
import 'package:possystem/settings/setting.dart';
import 'package:possystem/settings/theme_setting.dart';
import 'package:possystem/translator.dart';

const _themeNames = <ThemeMode, String>{
  ThemeMode.system: 'system',
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
};

const _orderOutlookNames = <OrderOutlookTypes, String>{
  OrderOutlookTypes.singleView: 'singleView',
  OrderOutlookTypes.slidingPanel: 'slidingPanel',
};

const _languageNames = ['繁體中文', 'English'];

const _supportedLanguages = ['zh', 'en'];

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = SettingsProvider.instance;
    final theme = settings.getSetting<ThemeSetting>();
    final language = settings.getSetting<LanguageSetting>();
    final orderAwakening = settings.getSetting<OrderAwakeningSetting>();
    final orderOutlook = settings.getSetting<OrderOutlookSetting>();

    final selectedLanguage =
        _supportedLanguages.indexOf(language.value.languageCode);

    return Scaffold(
      appBar: AppBar(leading: const PopButton()),
      body: ListView(
        children: <Widget>[
          CardTile(
            key: const Key('setting.theme'),
            title: Text(S.settingThemeTitle),
            subtitle: Text(S.settingThemeTypes(_themeNames[theme.value]!)),
            trailing: const Icon(Icons.arrow_forward_ios_sharp),
            onTap: () => _navigateItemList(
              (index) => theme.update(ThemeMode.values[index]),
              title: S.settingThemeTitle,
              items: ThemeMode.values
                  .map<String>((e) => S.settingThemeTypes(_themeNames[e]!))
                  .toList(),
              selected: theme.value.index,
            ),
          ),
          CardTile(
            key: const Key('setting.language'),
            title: Text(S.settingLanguageTitle),
            subtitle: Text(_languageNames[selectedLanguage]),
            trailing: const Icon(Icons.arrow_forward_ios_sharp),
            onTap: () => _navigateItemList(
              (index) => language.update(Locale(_supportedLanguages[index])),
              title: S.settingLanguageTitle,
              selected: selectedLanguage,
              items: _languageNames,
            ),
          ),
          const SizedBox(height: kSpacing2),
          CardTile(
            key: const Key('setting.outlook_order'),
            title: Text(S.settingOrderOutlookTitle),
            subtitle: Text(S.settingOrderOutlookTypes(
                _orderOutlookNames[orderOutlook.value]!)),
            trailing: const Icon(Icons.arrow_forward_ios_sharp),
            onTap: () => _navigateItemList(
              (index) => orderOutlook.update(OrderOutlookTypes.values[index]),
              title: S.settingOrderOutlookTitle,
              items: OrderOutlookTypes.values
                  .map(
                      (e) => S.settingOrderOutlookTypes(_orderOutlookNames[e]!))
                  .toList(),
              selected: orderOutlook.value.index,
            ),
          ),
          CardTile(
            title: Text(S.settingOrderAwakeningTitle),
            trailing: FeatureSwitch(
              key: const Key('setting.feature.awake_ordering'),
              value: orderAwakening.value,
              onChanged: (value) => orderAwakening.update(value),
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
