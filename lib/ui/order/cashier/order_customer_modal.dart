import 'package:flutter/material.dart';
import 'package:possystem/components/style/radio_text.dart';
import 'package:possystem/components/style/appbar_text_button.dart';
import 'package:possystem/components/style/pop_button.dart';
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
        leading: const PopButton(),
        title: Text(S.orderCustomerSettingTitle),
        actions: [
          AppbarTextButton(
            key: const Key('cashier.customer.next'),
            onPressed: () => Navigator.of(context).pop(Routes.orderCalculator),
            child: Text(S.orderCustomerSettingActionsDone),
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
  late String? selectedId;

  @override
  Widget build(BuildContext context) {
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
                key: Key('cashier.customer.${widget.setting.id}.${option.id}'),
                onChanged: (isSelected) {
                  setState(() => selectedId = isSelected ? option.id : null);
                  selectOption(option, isSelected);
                },
                isTogglable: true,
                isSelected: selectedId == option.id,
                text: option.name,
              )
          ]),
        ),
      ),
    ]);
  }

  @override
  void initState() {
    super.initState();
    selectedId = Cart.instance.customerSettings[widget.setting.id] ??
        widget.setting.defaultOption?.id;
  }

  void selectOption(CustomerSettingOption option, bool isSelected) {
    if (isSelected) {
      Cart.instance.customerSettings[widget.setting.id] = option.id;
    } else {
      // disable it
      Cart.instance.customerSettings[widget.setting.id] = '';
    }
  }
}
