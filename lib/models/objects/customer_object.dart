import 'package:possystem/models/customer/customer_setting_option.dart';

import '../customer/customer_setting.dart';
import '../model_object.dart';

class CustomerSettingObject extends ModelObject<CustomerSetting> {
  final String? id;

  final String? name;

  final int? index;

  final CustomerSettingOptionMode? mode;

  final Iterable<CustomerSettingOptionObject> options;

  CustomerSettingObject({
    this.id,
    this.name,
    this.index,
    this.mode,
    this.options = const Iterable.empty(),
  });

  factory CustomerSettingObject.build(Map<String, Object?> data) {
    return CustomerSettingObject(
      id: (data['id'] as int).toString(),
      name: data['name'] as String,
      index: data['index'] as int,
      mode: CustomerSettingOptionMode.values[data['mode'] as int],
    );
  }

  @override
  Map<String, Object?> diff(CustomerSetting model) {
    final result = <String, Object?>{};
    if (name != null && name != model.name) {
      model.name = name!;
      result['name'] = name!;
    }
    if (mode != null && mode != model.mode) {
      model.mode = mode!;
      result['mode'] = mode!.index;
    }
    return result;
  }

  @override
  Map<String, Object> toMap() {
    return {
      'name': name!,
      'index': index!,
      'mode': mode!.index,
    };
  }
}

class CustomerSettingOptionObject extends ModelObject<CustomerSettingOption> {
  final int? customerSettingId;

  final String? id;

  final String? name;

  final int? index;

  final bool? isDefault;

  final num? modeValue;

  const CustomerSettingOptionObject({
    this.customerSettingId,
    this.id,
    this.name,
    this.index,
    this.isDefault,
    this.modeValue,
  });

  factory CustomerSettingOptionObject.build(Map<String, Object?> data) {
    return CustomerSettingOptionObject(
      id: (data['id'] as int).toString(),
      name: data['name'] as String,
      index: data['index'] as int,
      isDefault: data['isDefault'] == 1,
      modeValue: data['modeValue'] as num?,
    );
  }

  @override
  Map<String, Object?> toMap() {
    return {
      'customerSettingId': customerSettingId,
      'name': name,
      'index': index,
      'isDefault': (isDefault ?? false) ? 1 : 0,
      'modeValue': modeValue,
    };
  }

  @override
  Map<String, Object?> diff(CustomerSettingOption model) {
    final result = <String, Object?>{};
    if (name != null && name != model.name) {
      model.name = name!;
      result['name'] = name!;
    }
    if (isDefault != null && isDefault != model.isDefault) {
      model.isDefault = isDefault!;
      result['isDefault'] = isDefault! ? 1 : 0;
    }
    if (modeValue != model.modeValue) {
      model.modeValue = modeValue;
      result['modeValue'] = modeValue;
    }
    return result;
  }
}

enum CustomerSettingOptionMode {
  statOnly,
  changePrice,
  changeDiscount,
}

const customerSettingOptionModeString = {
  CustomerSettingOptionMode.statOnly: '一般',
  CustomerSettingOptionMode.changePrice: '變價',
  CustomerSettingOptionMode.changeDiscount: '折扣',
};
