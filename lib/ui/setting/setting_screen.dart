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

const _outlookOrderNames = <OrderOutlookTypes, String>{
  OrderOutlookTypes.slidingPanel: '酷炫面板',
  OrderOutlookTypes.singleView: '經典模式',
};

const _themeNames = <ThemeMode, String>{
  ThemeMode.system: 'system',
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
};

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

    final selectedLanguage = LanguageSetting.supports.indexOf(language.value);

    return Scaffold(
      appBar: AppBar(
        title: Text(tt('home.setting')),
        leading: const PopButton(),
      ),
      body: ListView(
        children: <Widget>[
          CardTile(
            key: const Key('setting.theme'),
            title: Text(tt('setting.theme.title')),
            subtitle: Text(tt('setting.theme.${_themeNames[theme.value]}')),
            trailing: const Icon(Icons.arrow_forward_ios_sharp),
            onTap: () => _navigateItemList(
              (index) => theme.update(ThemeMode.values[index]),
              title: tt('setting.theme.title'),
              items: ThemeMode.values
                  .map<String>((e) => tt('setting.theme.${_themeNames[e]}'))
                  .toList(),
              selected: theme.value.index,
            ),
          ),
          CardTile(
            key: const Key('setting.language'),
            title: Text(tt('setting.language.title')),
            subtitle: Text(LanguageSetting.supportNames[selectedLanguage]),
            trailing: const Icon(Icons.arrow_forward_ios_sharp),
            onTap: () => _navigateItemList(
              (index) => language.update(LanguageSetting.supports[index]),
              title: tt('setting.language.title'),
              items: LanguageSetting.supportNames,
              selected: selectedLanguage,
            ),
          ),
          const SizedBox(height: kSpacing2),
          CardTile(
            key: const Key('setting.outlook_order'),
            title: const Text('點餐的外觀'),
            subtitle: Text(_outlookOrderNames[orderOutlook.value]!),
            trailing: const Icon(Icons.arrow_forward_ios_sharp),
            onTap: () => _navigateItemList(
              (index) => orderOutlook.update(OrderOutlookTypes.values[index]),
              title: '點餐的外觀',
              items: OrderOutlookTypes.values
                  .map((e) => _outlookOrderNames[e]!)
                  .toList(),
              selected: orderOutlook.value.index,
            ),
          ),
          CardTile(
            title: const Text('點餐時不關閉螢幕'),
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
