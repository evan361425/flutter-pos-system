import 'package:flutter/material.dart';
import 'package:possystem/components/radio_text.dart';
import 'package:possystem/components/style/appbar_text_button.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/customer/customer_setting.dart';
import 'package:possystem/models/customer/customer_setting_option.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/models/repository/customer_settings.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

class OrderCustomerModal extends StatelessWidget {
  const OrderCustomerModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: PopButton(),
        title: Text('顧客設定'),
        actions: [
          AppbarTextButton(
            onPressed: () async {
              final result = await Navigator.of(context)
                  .pushReplacementNamed<bool, bool>(Routes.orderCalculator);

              if (result == true) {
                showSuccessSnackbar(context, tt('success'));
              }
            },
            child: Text('下一步'),
          ),
        ],
      ),
      body: Padding(
        // bottom for floating button
        padding: const EdgeInsets.all(kSpacing2),
        child: ListView(children: [
          for (final item in CustomerSettings.instance.selectableItemList)
            _CustomerSettingGroup(item),
        ]),
      ),
    );
  }
}

class _CustomerSettingGroup extends StatefulWidget {
  final CustomerSetting setting;

  const _CustomerSettingGroup(this.setting);

  @override
  State<_CustomerSettingGroup> createState() => _CustomerSettingGroupState();
}

class _CustomerSettingGroupState extends State<_CustomerSettingGroup> {
  @override
  Widget build(BuildContext context) {
    final selected = Cart.instance.customerSettings[widget.setting.id] ??
        widget.setting.defaultOption?.id;

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(widget.setting.name, style: Theme.of(context).textTheme.headline5),
      const SizedBox(height: kSpacing0),
      Card(
        margin: const EdgeInsets.only(bottom: kSpacing2),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kSpacing1),
          child: Wrap(spacing: kSpacing0, children: [
            for (final option in widget.setting.itemList)
              RadioText(
                  groupId: 'order.customer.${widget.setting.id}',
                  onSelected: (isSelected) => selectOption(option, isSelected),
                  value: option.id,
                  isTogglable: true,
                  isSelected: selected == option.id,
                  text: option.name)
          ]),
        ),
      ),
    ]);
  }

  void selectOption(CustomerSettingOption option, bool isSelected) {
    setState(() {
      if (isSelected) {
        Cart.instance.customerSettings[widget.setting.id] = option.id;
      } else {
        Cart.instance.customerSettings.remove(widget.setting.id);
      }
    });
  }
}
