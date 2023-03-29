import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:possystem/components/scaffold/item_list_scaffold.dart';
import 'package:possystem/components/sign_in_button.dart';
import 'package:possystem/components/style/card_tile.dart';
import 'package:possystem/components/style/outlined_text.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/services/auth.dart';
import 'package:possystem/settings/cashier_warning.dart';
import 'package:possystem/settings/collect_events_setting.dart';
import 'package:possystem/settings/language_setting.dart';
import 'package:possystem/settings/order_awakening_setting.dart';
import 'package:possystem/settings/order_outlook_setting.dart';
import 'package:possystem/settings/order_product_axis_count_setting.dart';
import 'package:possystem/settings/settings_provider.dart';
import 'package:possystem/settings/theme_setting.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/setting/widgets/feature_slider.dart';
import 'package:possystem/ui/setting/widgets/feature_switch.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final theme = SettingsProvider.of<ThemeSetting>();
  final language = SettingsProvider.of<LanguageSetting>();
  final orderAwakening = SettingsProvider.of<OrderAwakeningSetting>();
  final orderOutlook = SettingsProvider.of<OrderOutlookSetting>();
  final orderCount = SettingsProvider.of<OrderProductAxisCountSetting>();
  final cashierWarning = SettingsProvider.of<CashierWarningSetting>();
  final collectEvents = SettingsProvider.of<CollectEventsSetting>();

  @override
  Widget build(BuildContext context) {
    final selectedLanguage = LanguageSetting.supported
        .indexWhere((e) => e.languageCode == language.value.languageCode);
    const flavor = String.fromEnvironment('appFlavor');

    return Scaffold(
      appBar: AppBar(leading: const PopButton()),
      body: ListView(
        children: <Widget>[
          const SizedBox(height: 8.0),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final info = snapshot.data;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (info != null) Text('版本：${info.version}'),
                  const SizedBox(width: 8.0),
                  OutlinedText((kDebugMode ? '_' : '') + flavor.toUpperCase()),
                ],
              );
            },
          ),
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SignInButton(signedInWidget: signedInWidget),
          ),
          const SizedBox(height: 8.0),
          CardTile(
            key: const Key('setting.theme'),
            title: Text(S.settingThemeTitle),
            subtitle: Text(S.settingThemeTypes(theme.value.name)),
            trailing: const Icon(Icons.arrow_forward_ios_sharp),
            onTap: () => _navigateItemList(
              (index) => theme.update(ThemeMode.values[index]),
              title: S.settingThemeTitle,
              items: ThemeMode.values
                  .map<String>((e) => S.settingThemeTypes(e.name))
                  .toList(),
              selected: theme.value.index,
            ),
          ),
          CardTile(
            key: const Key('setting.language'),
            title: Text(S.settingLanguageTitle),
            subtitle: Text(LanguageSetting.supportedNames[selectedLanguage]),
            trailing: const Icon(Icons.arrow_forward_ios_sharp),
            onTap: () => _navigateItemList(
              (index) => language.update(LanguageSetting.supported[index]),
              title: S.settingLanguageTitle,
              selected: selectedLanguage,
              items: LanguageSetting.supportedNames,
            ),
          ),
          const SizedBox(height: kSpacing2),
          CardTile(
            key: const Key('setting.outlook_order'),
            title: Text(S.settingOrderOutlookTitle),
            subtitle: Text(S.settingOrderOutlookTypes(orderOutlook.value.name)),
            trailing: const Icon(Icons.arrow_forward_ios_sharp),
            onTap: () => _navigateItemList(
              (index) => orderOutlook.update(OrderOutlookTypes.values[index]),
              title: S.settingOrderOutlookTitle,
              selected: orderOutlook.value.index,
              items: OrderOutlookTypes.values
                  .map((e) => S.settingOrderOutlookTypes(e.name))
                  .toList(),
              tips: [
                '點餐時下方會有可拉動的面板，內含點餐中的資訊，適合小螢幕的手機',
                '所有資訊顯示在單一螢幕中，適合大螢幕的平板',
              ],
            ),
          ),
          CardTile(
            key: const Key('setting.cashier_warning'),
            title: Text(S.settingCashierWarningTitle),
            subtitle:
                Text(S.settingCashierWarningTypes(cashierWarning.value.name)),
            trailing: const Icon(Icons.arrow_forward_ios_sharp),
            onTap: () => _navigateItemList(
              (index) =>
                  cashierWarning.update(CashierWarningTypes.values[index]),
              title: S.settingCashierWarningTitle,
              selected: cashierWarning.value.index,
              items: CashierWarningTypes.values
                  .map((e) => S.settingCashierWarningTypes(e.name))
                  .toList(),
              tips: [
                '收銀機若使用小錢會出現提示，例如收銀機 5 塊錢不夠了並嘗試用 1 塊錢去找 5 塊錢',
                null,
                null,
              ],
            ),
          ),
          FeatureSlider(
            sliderKey: const Key('setting.order_product_count'),
            title: '點餐時每行顯示幾個產品',
            value: orderCount.value,
            max: 5,
            minLabel: '純文字顯示',
            hintText: '設定「零」則點餐時僅會以文字顯示',
            onChanged: (value) => orderCount.update(value),
          ),
          CardTile(
            title: Text(S.settingOrderAwakeningTitle),
            trailing: FeatureSwitch(
              key: const Key('setting.awake_ordering'),
              value: orderAwakening.value,
              onChanged: (value) => orderAwakening.update(value),
            ),
          ),
          const Divider(),
          CardTile(
            title: const Text('收集錯誤訊息和事件'),
            subtitle: const Text('當應用程式發生錯誤時，寄送錯誤訊息，以幫助應用程式成長'),
            trailing: FeatureSwitch(
              key: const Key('setting.collect_events'),
              value: collectEvents.value,
              onChanged: (value) => collectEvents.update(value),
            ),
          ),
        ],
      ),
    );
  }

  Widget signedInWidget(User user) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text('HI，${user.displayName}'),
      OutlinedButton(
        key: const Key('setting.sign_out'),
        onPressed: () async {
          await Auth.instance.signOut();
        },
        child: const Text('登出'),
      ),
    ]);
  }

  void _navigateItemList(
    Future<void> Function(int) onChanged, {
    required String title,
    required List<String> items,
    required int selected,
    List<String?>? tips,
  }) async {
    final newSelected = await Navigator.of(context).push<int>(
      MaterialPageRoute(
          builder: (_) => ItemListScaffold(
                title: title,
                items: items,
                selected: selected,
                tips: tips,
              )),
    );

    if (newSelected != null) {
      await onChanged(newSelected);
      setState(() {});
    }
  }
}
