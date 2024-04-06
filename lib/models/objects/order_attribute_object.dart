import 'package:possystem/models/order/order_attribute.dart';
import 'package:possystem/models/order/order_attribute_option.dart';

import '../model_object.dart';

class OrderAttributeObject extends ModelObject<OrderAttribute> {
  final String? id;

  final String? name;

  final int? index;

  final OrderAttributeMode? mode;

  final Iterable<OrderAttributeOptionObject> options;

  OrderAttributeObject({
    this.id,
    this.name,
    this.index,
    this.mode,
    this.options = const Iterable.empty(),
  });

  factory OrderAttributeObject.build(Map<String, Object?> data) {
    final options = (data['options'] ?? <String, Object?>{}) as Map<String, Object?>;

    return OrderAttributeObject(
      id: data['id'].toString(),
      name: data['name'] as String,
      index: data['index'] as int,
      mode: OrderAttributeMode.values[data['mode'] as int],
      options: options.entries
          .map<OrderAttributeOptionObject>((e) => OrderAttributeOptionObject.build({
                'id': e.key,
                ...e.value as Map<String, Object?>,
              }))
          .toList(),
    );
  }

  @override
  Map<String, Object?> diff(OrderAttribute model) {
    final prefix = model.prefix;
    final result = <String, Object?>{};
    if (name != null && name != model.name) {
      model.name = name!;
      result['$prefix.name'] = name!;
    }
    if (mode != null && mode != model.mode) {
      model.mode = mode!;
      for (var option in model.items) {
        option.modeValue = null;
        result['${option.prefix}.modeValue'] = null;
      }
      result['$prefix.mode'] = mode!.index;
    }
    return result;
  }

  @override
  Map<String, Object> toMap() {
    return {
      'name': name!,
      'index': index!,
      'mode': mode!.index,
      'options': {for (var option in options) option.id: option.toMap()},
    };
  }
}

class OrderAttributeOptionObject extends ModelObject<OrderAttributeOption> {
  final String? id;

  final String? name;

  final int? index;

  final bool? isDefault;

  final num? modeValue;

  const OrderAttributeOptionObject({
    this.id,
    this.name,
    this.index,
    this.isDefault,
    this.modeValue,
  });

  factory OrderAttributeOptionObject.build(Map<String, Object?> data) {
    return OrderAttributeOptionObject(
      id: data['id'].toString(),
      name: data['name'] as String,
      index: data['index'] as int,
      // backward compatible for DB, it will be 1 if true
      isDefault: data['isDefault'] == 1 || data['isDefault'] == true,
      modeValue: data['modeValue'] as num?,
    );
  }

  @override
  Map<String, Object?> toMap() {
    return {
      'name': name,
      'index': index,
      'isDefault': isDefault ?? false,
      'modeValue': modeValue,
    };
  }

  @override
  Map<String, Object?> diff(OrderAttributeOption model) {
    final prefix = model.prefix;
    final result = <String, Object?>{};
    if (name != null && name != model.name) {
      model.name = name!;
      result['$prefix.name'] = name!;
    }
    if (isDefault != null && isDefault != model.isDefault) {
      model.isDefault = isDefault!;
      result['$prefix.isDefault'] = isDefault!;
    }
    if (modeValue != model.modeValue) {
      model.modeValue = modeValue;
      result['$prefix.modeValue'] = modeValue;
    }
    return result;
  }
}

enum OrderAttributeMode {
  statOnly,
  changePrice,
  changeDiscount,
}
