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
    final subtitle = setting.shouldHaveModeValue && option.modeValue != null
        ? setting.mode == CustomerSettingOptionMode.changePrice
            ? _priceSubtitle(option)
            : _discountSubtitle(option)
        : null;

    return ListTile(
      title: Text(option.name),
      subtitle: subtitle,
      trailing: option.isDefault ? OutlinedText('預設') : null,
    );
  }

  Text _discountSubtitle(CustomerSettingOption option) {
    final value = option.modeValue!;
    if (value == 0) {
      return Text('使訂單免費');
    }

    return Text(value >= 100
        ? '增加 ${(value / 100).toStringAsFixed(2)} 倍'
        : '打 ${(value % 10) == 0 ? (value / 10).toStringAsFixed(0) : value} 折');
  }

  Text? _priceSubtitle(CustomerSettingOption option) {
    final value = option.modeValue!;
    if (value == 0) {
      return null;
    }
    return Text(value > 0 ? '增加 $value 元' : '減少 $value 元');
  }
}

enum _Action {
  delete,
}
