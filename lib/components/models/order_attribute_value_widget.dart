import 'package:flutter/material.dart';
import 'package:possystem/models/objects/order_attribute_object.dart';
import 'package:possystem/settings/currency_setting.dart';

class OrderAttributeValueWidget extends StatelessWidget {
  final OrderAttributeMode? mode;
  final num? value;

  const OrderAttributeValueWidget(
    this.mode,
    this.value, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final name = getValueName(mode, value);
    return name == '' ? const SizedBox.shrink() : Text(name);
  }

  static String getValueName(OrderAttributeMode? mode, num? value) {
    if (value == null || mode == null || mode == OrderAttributeMode.statOnly) {
      return '';
    }

    final modeValue = value;
    if (mode == OrderAttributeMode.changeDiscount) {
      final value = modeValue.toInt();
      return value == 0
          ? '免費'
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
