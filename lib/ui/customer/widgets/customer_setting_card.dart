import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/dialog/delete_dialog.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/expansion_action_button.dart';
import 'package:possystem/components/style/outlined_text.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/customer/customer_setting.dart';
import 'package:possystem/models/customer/customer_setting_option.dart';
import 'package:possystem/models/objects/customer_object.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

class CustomerSettingCard extends StatelessWidget {
  final CustomerSetting setting;

  const CustomerSettingCard({
    Key? key,
    required this.setting,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mode = customerSettingOptionModeString[setting.mode];
    final defaultName = setting.defaultOption?.name ?? '無';

    final addOptionBtn = ExpansionActionButton(
      onPressed: () => Navigator.of(context).pushNamed(
        Routes.customerSettingOption,
        arguments: setting,
      ),
      icon: Icon(KIcons.add),
      label: Text('新增顧客設定選項'),
    );
    final editSettingBtn = ExpansionActionButton(
      onPressed: () => Navigator.of(context).pushNamed(
        Routes.customerModal,
        arguments: setting,
      ),
      icon: Icon(Icons.text_fields_sharp),
      label: Text('編輯資訊'),
    );
    final reorderOptionsBtn = ExpansionActionButton(
      onPressed: () => Navigator.of(context).pushNamed(
        Routes.customerSettingReorder,
        arguments: setting,
      ),
      icon: Icon(Icons.reorder_sharp),
      label: Text('排序'),
    );
    final deleteSettingBtn = ExpansionActionButton(
      isDanger: true,
      onPressed: () => DeleteDialog.show(
        context,
        deleteCallback: setting.remove,
        warningContent: Text(tt('delete_confirm', {'name': setting.name})),
      ),
      icon: Icon(KIcons.delete),
      label: Text('刪除設定'),
    );

    return Card(
      child: Column(children: <Widget>[
        ExpansionTile(
          title: Text(setting.name),
          subtitle: MetaBlock.withString(context, [
            '種類：$mode',
            '預設：$defaultName',
          ]),
          childrenPadding: const EdgeInsets.all(kSpacing2),
          expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            addOptionBtn,
            for (final item in setting.items) _OptionTile(item),
            editSettingBtn,
            reorderOptionsBtn,
            deleteSettingBtn,
          ],
        ),
      ]),
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
      title: Text(option.name),
      subtitle: subtitle.isEmpty ? null : Text(subtitle),
      trailing: option.isDefault ? OutlinedText('預設') : null,
      onLongPress: () => BottomSheetActions.withDelete<int>(
        context,
        deleteValue: 0,
        warningContent: Text(tt('delete_confirm', {'name': option.name})),
        deleteCallback: () => option.remove(),
      ),
      onTap: () => Navigator.of(context).pushNamed<CustomerSettingOption>(
        Routes.customerSettingOption,
        arguments: option,
      ),
    );
  }
}
