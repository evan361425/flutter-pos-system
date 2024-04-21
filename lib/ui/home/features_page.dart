import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:possystem/components/scaffold/item_list_scaffold.dart';
import 'package:possystem/components/sign_in_button.dart';
import 'package:possystem/components/style/outlined_text.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/services/auth.dart';
import 'package:possystem/settings/checkout_warning.dart';
import 'package:possystem/settings/collect_events_setting.dart';
import 'package:possystem/settings/language_setting.dart';
import 'package:possystem/settings/order_awakening_setting.dart';
import 'package:possystem/settings/order_outlook_setting.dart';
import 'package:possystem/settings/order_product_axis_count_setting.dart';
import 'package:possystem/settings/settings_provider.dart';
import 'package:possystem/settings/theme_setting.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/home/widgets/feature_slider.dart';
import 'package:possystem/ui/home/widgets/feature_switch.dart';

class FeaturesPage extends StatefulWidget {
  const FeaturesPage({super.key});

  @override
  State<FeaturesPage> createState() => _FeaturesPageState();
}

class _FeaturesPageState extends State<FeaturesPage> {
  final theme = SettingsProvider.of<ThemeSetting>();
  final language = SettingsProvider.of<LanguageSetting>();
  final orderAwakening = SettingsProvider.of<OrderAwakeningSetting>();
  final orderOutlook = SettingsProvider.of<OrderOutlookSetting>();
  final orderCount = SettingsProvider.of<OrderProductAxisCountSetting>();
  final checkoutWarning = SettingsProvider.of<CheckoutWarningSetting>();
  final collectEvents = SettingsProvider.of<CollectEventsSetting>();

  @override
  Widget build(BuildContext context) {
    final selectedLanguage = LanguageSetting.supported.indexWhere((e) => e.languageCode == language.value.languageCode);
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
                  if (info != null) Text(S.settingVersion(info.version)),
                  const SizedBox(width: 8.0),
                  OutlinedText((kDebugMode ? '_' : '') + flavor.toUpperCase()),
                ],
              );
            },
          ),
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SignInButton(
              signedInWidgetBuilder: (user) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(S.settingWelcome(user?.displayName ?? '')),
                  OutlinedButton(
                    key: const Key('feature.sign_out'),
                    onPressed: () async {
                      await Auth.instance.signOut();
                    },
                    child: Text(S.settingLogoutBtn),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            key: const Key('feature.theme'),
            leading: const Icon(Icons.palette_outlined),
            title: Text(S.settingThemeTitle),
            subtitle: Text(S.settingThemeName(theme.value.name)),
            trailing: const Icon(Icons.arrow_forward_ios_sharp),
            onTap: () => _buildChoiceList(
              (index) => theme.update(ThemeMode.values[index]),
              title: S.settingThemeTitle,
              items: ThemeMode.values.map<String>((e) => S.settingThemeName(e.name)).toList(),
              selected: theme.value.index,
            ),
          ),
          ListTile(
            key: const Key('feature.language'),
            leading: const Icon(Icons.language_outlined),
            title: Text(S.settingLanguageTitle),
            subtitle: Text(LanguageSetting.supportedNames[selectedLanguage]),
            trailing: const Icon(Icons.arrow_forward_ios_sharp),
            onTap: () => _buildChoiceList(
              (index) => language.update(LanguageSetting.supported[index]),
              title: S.settingLanguageTitle,
              selected: selectedLanguage,
              items: LanguageSetting.supportedNames,
            ),
          ),
          const Divider(),
          ListTile(
            key: const Key('feature.outlook_order'),
            leading: const Icon(Icons.library_books_outlined),
            title: Text(S.settingOrderOutlookTitle),
            subtitle: Text(S.settingOrderOutlookName(orderOutlook.value.name)),
            trailing: const Icon(Icons.arrow_forward_ios_sharp),
            onTap: () => _buildChoiceList(
              (index) => orderOutlook.update(OrderOutlookTypes.values[index]),
              title: S.settingOrderOutlookTitle,
              selected: orderOutlook.value.index,
              items: OrderOutlookTypes.values.map((e) => S.settingOrderOutlookName(e.name)).toList(),
              tips: OrderOutlookTypes.values.map((e) => S.settingOrderOutlookTip(e.name)).toList(),
            ),
          ),
          ListTile(
            key: const Key('feature.checkout_warning'),
            leading: const Icon(Icons.store_mall_directory_outlined),
            title: Text(S.settingCheckoutWarningTitle),
            subtitle: Text(S.settingCheckoutWarningName(checkoutWarning.value.name)),
            trailing: const Icon(Icons.arrow_forward_ios_sharp),
            onTap: () => _buildChoiceList(
              (index) => checkoutWarning.update(CheckoutWarningTypes.values[index]),
              title: S.settingCheckoutWarningTitle,
              selected: checkoutWarning.value.index,
              items: CheckoutWarningTypes.values.map((e) => S.settingCheckoutWarningName(e.name)).toList(),
              tips: CheckoutWarningTypes.values.map((e) => S.settingCheckoutWarningTip(e.name)).toList(),
            ),
          ),
          // TODO: After using RWD, this feature is not necessary
          FeatureSlider(
            sliderKey: const Key('feature.order_product_count'),
            title: S.settingOrderProductCountTitle,
            value: orderCount.value,
            max: 5,
            minLabel: S.settingOrderProductCountMinLabel,
            hintText: S.settingOrderProductCountHint,
            onChanged: (value) => orderCount.update(value),
          ),
          ListTile(
            leading: const Icon(Icons.remove_red_eye_outlined),
            title: Text(S.settingOrderAwakeningTitle),
            subtitle: Text(S.settingOrderAwakeningDescription),
            trailing: FeatureSwitch(
              key: const Key('feature.awake_ordering'),
              value: orderAwakening.value,
              onChanged: (value) => orderAwakening.update(value),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.report_outlined),
            title: Text(S.settingReportTitle),
            subtitle: Text(S.settingReportDescription),
            trailing: FeatureSwitch(
              key: const Key('feature.collect_events'),
              value: collectEvents.value,
              onChanged: (value) => collectEvents.update(value),
            ),
          ),
        ],
      ),
    );
  }

  void _buildChoiceList(
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
