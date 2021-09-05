import 'package:flutter/material.dart';
import 'package:possystem/components/slidable_item_list.dart';
import 'package:possystem/components/style/outlined_text.dart';
import 'package:possystem/models/customer/customer_setting.dart';
import 'package:possystem/models/customer/customer_setting_option.dart';
import 'package:possystem/models/objects/customer_object.dart';
import 'package:possystem/routes.dart';

class CustomerSettingOptionList extends StatelessWidget {
  final CustomerSetting setting;

  const CustomerSettingOptionList({
    required this.setting,
  });

  @override
  Widget build(BuildContext context) {
    return SlidableItemList<CustomerSettingOption, _Action>(
      items: setting.itemList,
      deleteValue: _Action.delete,
      tileBuilder: _tileBuilder,
      handleTap: _handleTap,
      handleDelete: (_, item) => item.remove(),
    );
  }

  void _handleTap(BuildContext context, CustomerSettingOption option) {
    Navigator.of(context).pushNamed(
      Routes.customerSettingOption,
      arguments: option,
    );
  }

  Widget _tileBuilder(BuildContext _, int __, CustomerSettingOption option) {
    final mode = customerSettingOptionModeString[setting.mode];

    return ListTile(
      title: Text(option.name),
      subtitle: setting.shouldHaveModeValue
          ? Text(
              option.modeValue == null ? '無$mode' : '$mode：${option.modeValue}')
          : null,
      trailing: option.isDefault ? OutlinedText('預設') : null,
    );
  }
}

enum _Action {
  delete,
}
