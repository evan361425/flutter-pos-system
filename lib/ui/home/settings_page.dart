import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:possystem/components/sign_in_button.dart';
import 'package:possystem/components/style/outlined_text.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/services/auth.dart';
import 'package:possystem/settings/checkout_warning.dart';
import 'package:possystem/settings/collect_events_setting.dart';
import 'package:possystem/settings/language_setting.dart';
import 'package:possystem/settings/order_awakening_setting.dart';
import 'package:possystem/settings/theme_setting.dart';
import 'package:possystem/translator.dart';

class SettingsPage extends StatelessWidget {
  final String? focus;

  const SettingsPage({
    super.key,
    this.focus,
  });

  @override
  Widget build(BuildContext context) {
    const flavor = String.fromEnvironment('appFlavor');

    void navigateTo(Feature feature) {
      context.pushNamed(Routes.settingsFeature, pathParameters: {'feature': feature.name});
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.only(bottom: kFABSpacing, top: kTopSpacing),
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
          ListenableBuilder(
            listenable: ThemeSetting.instance,
            builder: (context, _) {
              return ListTile(
                key: const Key('feature.theme'),
                leading: const Icon(Icons.palette_outlined),
                title: Text(S.settingThemeTitle),
                subtitle: Text(S.settingThemeName(ThemeSetting.instance.value.name)),
                trailing: const Icon(Icons.navigate_next_outlined),
                onTap: () => navigateTo(Feature.theme),
              );
            },
          ),
          ListenableBuilder(
            listenable: LanguageSetting.instance,
            builder: (context, _) {
              return ListTile(
                key: const Key('feature.language'),
                leading: const Icon(Icons.language_outlined),
                title: Text(S.settingLanguageTitle),
                subtitle: Text(LanguageSetting.instance.language.title),
                trailing: const Icon(Icons.navigate_next_outlined),
                onTap: () => navigateTo(Feature.language),
              );
            },
          ),
          const Divider(),
          ListenableBuilder(
            listenable: CheckoutWarningSetting.instance,
            builder: (context, _) {
              return ListTile(
                key: const Key('feature.checkout_warning'),
                leading: const Icon(Icons.store_mall_directory_outlined),
                title: Text(S.settingCheckoutWarningTitle),
                subtitle: Text(S.settingCheckoutWarningName(CheckoutWarningSetting.instance.value.name)),
                trailing: const Icon(Icons.navigate_next_outlined),
                onTap: () => navigateTo(Feature.checkoutWarning),
              );
            },
          ),
          ListenableBuilder(
            listenable: OrderAwakeningSetting.instance,
            builder: (context, _) {
              return SwitchListTile.adaptive(
                key: const Key('feature.order_awakening'),
                secondary: const Icon(Icons.remove_red_eye_outlined),
                title: Text(S.settingOrderAwakeningTitle),
                subtitle: Text(S.settingOrderAwakeningDescription),
                autofocus: focus == 'orderAwakening',
                value: OrderAwakeningSetting.instance.value,
                onChanged: (value) => OrderAwakeningSetting.instance.update(value),
              );
            },
          ),
          const Divider(),
          ListenableBuilder(
            listenable: CollectEventsSetting.instance,
            builder: (context, _) {
              return SwitchListTile.adaptive(
                key: const Key('feature.collect_events'),
                secondary: const Icon(Icons.report_outlined),
                title: Text(S.settingReportTitle),
                subtitle: Text(S.settingReportDescription),
                autofocus: focus == 'collectEvents',
                value: CollectEventsSetting.instance.value,
                onChanged: (value) => CollectEventsSetting.instance.update(value),
              );
            },
          ),
          const SizedBox(height: kFABSpacing),
        ],
      ),
    );
  }
}

class ItemListScaffold extends StatelessWidget {
  final Feature feature;

  const ItemListScaffold({
    super.key,
    required this.feature,
  });

  @override
  Widget build(BuildContext context) {
    final hintStyle = TextStyle(color: Theme.of(context).hintColor);

    final selected = ValueNotifier<int>(feature.selected);
    return Scaffold(
      appBar: AppBar(
        title: Text(feature.title),
        leading: const PopButton(),
      ),
      body: ValueListenableBuilder(
        valueListenable: selected,
        builder: (context, value, child) => ListView(
          children: IterableZip([feature.itemTitles, feature.itemSubtitles])
              .mapIndexed((index, pair) => ListTile(
                    title: Text(pair[0]),
                    trailing: value == index ? const Icon(Icons.check_outlined) : null,
                    subtitle: Text(pair[1], style: hintStyle),
                    onTap: () async {
                      if (value != index) {
                        selected.value = index;
                        await feature.update(index);
                      }
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }
}

enum Feature {
  theme(),
  language(),
  checkoutWarning();

  const Feature();

  Iterable<String> get itemTitles {
    return switch (this) {
      Feature.theme => ThemeMode.values.map((e) => S.settingThemeName(e.name)),
      Feature.language => Language.values.map((e) => e.title),
      Feature.checkoutWarning => CheckoutWarningTypes.values.map((e) => S.settingCheckoutWarningName(e.name)),
    };
  }

  Iterable<String> get itemSubtitles {
    return switch (this) {
      Feature.theme => ThemeMode.values.map((e) => ''),
      Feature.language => Language.values.map((e) => ''),
      Feature.checkoutWarning => CheckoutWarningTypes.values.map((e) => S.settingCheckoutWarningTip(e.name)),
    };
  }

  String get title {
    return switch (this) {
      Feature.theme => S.settingThemeTitle,
      Feature.language => S.settingLanguageTitle,
      Feature.checkoutWarning => S.settingCheckoutWarningTitle,
    };
  }

  int get selected {
    return switch (this) {
      Feature.theme => ThemeSetting.instance.value.index,
      Feature.language => LanguageSetting.instance.language.index,
      Feature.checkoutWarning => CheckoutWarningSetting.instance.value.index,
    };
  }

  Future<void> update(int index) {
    return switch (this) {
      Feature.theme => ThemeSetting.instance.update(ThemeMode.values[index]),
      Feature.language => LanguageSetting.instance.update(Language.values[index]),
      Feature.checkoutWarning => CheckoutWarningSetting.instance.update(CheckoutWarningTypes.values[index]),
    };
  }
}
