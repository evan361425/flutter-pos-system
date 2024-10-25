import 'package:flutter/material.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/objects/order_attribute_object.dart';
import 'package:possystem/translator.dart';

class OrderAttributeValueWidget {
  static Widget? build(OrderAttributeMode? mode, num? value) {
    if (value == null || mode == null || mode == OrderAttributeMode.statOnly) {
      return null;
    }

    final name = _name(mode, value);
    return name == '' ? HintText(S.orderAttributeValueEmpty) : Text(name);
  }

  static String _name(OrderAttributeMode mode, num value) {
    final modeValue = value;
    if (mode == OrderAttributeMode.changeDiscount) {
      final value = modeValue.toInt() / 100;
      return value == 0
          ? S.orderAttributeValueFree
          : value >= 1
              ? S.orderAttributeValueDiscountIncrease(value)
              : S.orderAttributeValueDiscountDecrease(value);
    } else {
      final value = modeValue.toCurrency();
      return modeValue == 0
          ? ''
          : modeValue > 0
              ? S.orderAttributeValuePriceIncrease(value)
              : S.orderAttributeValuePriceDecrease(value);
    }
  }
}
