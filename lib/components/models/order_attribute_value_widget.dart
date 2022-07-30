import 'package:flutter/material.dart';
import 'package:possystem/models/objects/order_attribute_object.dart';
import 'package:possystem/models/order/order_attribute_option.dart';
import 'package:possystem/settings/currency_setting.dart';

class OrderAttributeValueWidget extends StatelessWidget {
  final OrderAttributeOption option;

  const OrderAttributeValueWidget(
    this.option, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final name = getValueName();
    return name == '' ? const SizedBox.shrink() : Text(name);
  }

  String getValueName() {
    final mode = option.attribute.mode;
    final modeValue = option.modeValue;
    if (modeValue == null || mode == OrderAttributeMode.statOnly) {
      return '';
    }

    if (mode == OrderAttributeMode.changeDiscount) {
      final value = modeValue.toInt();
      return value == 0
          ? '使訂單免費'
          : value >= 100
              ? '增加 ${(value / 100).toStringAsFixed(2)} 倍'
              : '打 ${(value % 10) == 0 ? (value / 10).toStringAsFixed(0) : value} 折';
    } else {
      final value = modeValue.toCurrency();
      return modeValue == 0
          ? ''
          : modeValue > 0
              ? '增加 $value 元'
              : '減少 $value 元';
    }
  }
}
