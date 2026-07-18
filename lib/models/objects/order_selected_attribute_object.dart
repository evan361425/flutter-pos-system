import 'dart:math';

import 'package:possystem/models/objects/order_attribute_object.dart';
import 'package:possystem/models/objects/order_serializable.dart';
import 'package:possystem/models/order/order_attribute_option.dart';

/// Attribute helps get more info on the order.
class OrderSelectedAttributeObject extends OrderSerializable {
  /// ID of database row
  final int id;

  /// The attribute name, for example: age.
  final String name;

  /// The attribute's option name, for example: bellow 18.
  final String optionName;

  /// The attribute mode which help to identify this attribute usage.
  final OrderAttributeMode mode;

  /// The mode value, for example decrease order price 10 dollars.
  final num? modeValue;

  /// ID of attribute, help restore data from stashed.
  final String attributeId;

  /// ID of attribute's option, help restore data from stashed.
  final String optionId;

  /// Should not use the default value which only for help on test.
  const OrderSelectedAttributeObject({
    this.id = 0,
    this.name = '',
    this.optionName = '',
    this.mode = OrderAttributeMode.statOnly,
    this.modeValue,
    this.attributeId = '',
    this.optionId = '',
  });

  @override
  Map<String, Object?> toMap() {
    return {
      'name': name,
      'optionName': optionName,
      'mode': mode.index,
      'modeValue': modeValue,
    };
  }

  @override
  Map<String, Object?> toStashMap() {
    return {'attributeId': attributeId, 'optionId': optionId};
  }

  /// Create object from map.
  factory OrderSelectedAttributeObject.fromMap(Map<String, dynamic> data) {
    final modeIndex = min(
      data['mode'] as int? ?? 0,
      OrderAttributeMode.values.length - 1,
    );
    final mode = OrderAttributeMode.values[max(modeIndex, 0)];

    // null-safety to make test easy
    return OrderSelectedAttributeObject(
      id: data['id'] as int? ?? 0,
      name: data['name'] as String? ?? '',
      optionName: data['optionName'] as String? ?? '',
      mode: mode,
      modeValue: data['modeValue'],
    );
  }

  /// Create object from DB format.
  factory OrderSelectedAttributeObject.fromStashMap(Map<String, dynamic> data) {
    return OrderSelectedAttributeObject(
      attributeId: data['attributeId'],
      optionId: data['optionId'],
    );
  }

  /// Create object from model.
  factory OrderSelectedAttributeObject.fromModel(OrderAttributeOption option) {
    return OrderSelectedAttributeObject(
      name: option.attribute.name,
      optionName: option.name,
      mode: option.mode,
      modeValue: option.modeValue,
      attributeId: option.attribute.id,
      optionId: option.id,
    );
  }
}
