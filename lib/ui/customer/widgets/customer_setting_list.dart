import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/outlined_text.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/customer/customer_setting.dart';
import 'package:possystem/models/customer/customer_setting_option.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';

class CustomerSettingList extends StatelessWidget {
  final List<CustomerSetting> settings;

  const CustomerSettingList(this.settings, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(kSpacing1),
            child: HintText(S.totalCount(settings.length)),
          ),
          for (final setting in settings)
            ChangeNotifierProvider<CustomerSetting>.value(
              value: setting,
              child: const _CustomerSettingCard(),
            )
        ],
      ),
    );
  }
}

class _CustomerSettingCard extends StatelessWidget {
  const _CustomerSettingCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final setting = context.watch<CustomerSetting>();
    final mode = S.customerSettingModeNames(setting.mode);
    final defaultName =
        setting.defaultOption?.name ?? S.customerSettingMetaNoDefault;
    final key = 'customer_settings.${setting.id}';

    return Card(
      child: ExpansionTile(
        key: Key(key),
        title: Text(setting.name),
        subtitle: MetaBlock.withString(context, [
          S.customerSettingMetaMode(mode),
          S.customerSettingMetaDefault(defaultName),
        ]),
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: kSpacing2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  key: Key('$key.add'),
                  onPressed: () => Navigator.of(context).pushNamed(
                    Routes.customerSettingOption,
                    arguments: setting,
                  ),
                  icon: const Icon(KIcons.add),
                  label: Text(S.customerSettingOptionCreate),
                ),
                IconButton(
                  key: Key('$key.more'),
                  onPressed: () => showActions(context, setting),
                  enableFeedback: true,
                  icon: const Icon(KIcons.more),
                )
              ],
            ),
          ),
          for (final item in setting.itemList) _OptionTile(item),
        ],
      ),
    );
  }

  void showActions(BuildContext context, CustomerSetting setting) {
    BottomSheetActions.withDelete<int>(
      context,
      deleteValue: 0,
      actions: <BottomSheetAction<int>>[
        BottomSheetAction(
          title: Text(S.customerSettingUpdate),
          leading: const Icon(Icons.text_fields_sharp),
          navigateRoute: Routes.customerModal,
          navigateArgument: setting,
        ),
        BottomSheetAction(
          title: Text(S.customerSettingOptionIsReorder),
          leading: const Icon(Icons.reorder_sharp),
          navigateRoute: Routes.customerSettingReorder,
          navigateArgument: setting,
        ),
      ],
      warningContent: Text(S.dialogDeletionContent(setting.name, '')),
      deleteCallback: () => setting.remove(),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final CustomerSettingOption option;

  const _OptionTile(this.option);

  @override
  Widget build(BuildContext context) {
    final subtitle = option.modeValueName;

    return ListTile(
      key: Key('customer_setting.${option.setting.id}.${option.id}'),
      title: Text(option.name),
      subtitle: subtitle.isEmpty ? null : Text(subtitle),
      trailing: option.isDefault
          ? OutlinedText(S.customerSettingOptionIsDefault)
          : null,
      onLongPress: () => BottomSheetActions.withDelete<int>(
        context,
        deleteValue: 0,
        warningContent: Text(S.dialogDeletionContent(option.name, '')),
        deleteCallback: () => option.remove(),
      ),
      onTap: () => Navigator.of(context).pushNamed(
        Routes.customerSettingOption,
        arguments: option,
      ),
    );
  }
}
