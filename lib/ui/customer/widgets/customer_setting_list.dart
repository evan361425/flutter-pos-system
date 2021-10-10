import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/outlined_text.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/customer/customer_setting.dart';
import 'package:possystem/models/customer/customer_setting_option.dart';
import 'package:possystem/models/objects/customer_object.dart';
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
            child: HintText(tt('total_count', {'count': settings.length})),
          ),
          for (final setting in settings)
            ChangeNotifierProvider<CustomerSetting>.value(
              value: setting,
              child: _CustomerSettingCard(),
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
    final mode = customerSettingOptionModeString[setting.mode];
    final defaultName = setting.defaultOption?.name ?? '無';

    return Card(
      child: ExpansionTile(
        title: Text(setting.name),
        subtitle: MetaBlock.withString(context, [
          '種類：$mode',
          '預設：$defaultName',
        ]),
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: kSpacing2),
            child: Row(children: [
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pushNamed(
                  Routes.customerSettingOption,
                  arguments: setting,
                ),
                icon: Icon(KIcons.add),
                label: Text('新增顧客設定選項'),
              ),
              IconButton(
                onPressed: () => showActions(context, setting),
                icon: Icon(KIcons.more),
              )
            ]),
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
          title: Text('編輯資訊'),
          leading: Icon(Icons.text_fields_sharp),
          navigateRoute: Routes.customerModal,
          navigateArgument: setting,
        ),
        BottomSheetAction(
          title: Text('排序'),
          leading: Icon(Icons.reorder_sharp),
          navigateRoute: Routes.customerSettingReorder,
          navigateArgument: setting,
        ),
      ],
      warningContent: Text(tt('delete_confirm', {'name': setting.name})),
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
      title: Text(option.name, style: Theme.of(context).textTheme.headline6),
      subtitle: subtitle.isEmpty ? null : Text(subtitle),
      trailing: option.isDefault ? OutlinedText('預設') : null,
      onLongPress: () => BottomSheetActions.withDelete<int>(
        context,
        deleteValue: 0,
        warningContent: Text(tt('delete_confirm', {'name': option.name})),
        deleteCallback: () => option.remove(),
      ),
      onTap: () => Navigator.of(context).pushNamed(
        Routes.customerSettingOption,
        arguments: option,
      ),
    );
  }
}
