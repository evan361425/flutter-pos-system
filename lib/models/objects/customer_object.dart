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
  Map<String, Object?> diff(CustomerSetting setting) {
    final result = <String, Object?>{};
    if (name != null && name != setting.name) {
      setting.name = name!;
      result['name'] = name!;
    }
    if (index != null && index != setting.index) {
      setting.index = index!;
      result['index'] = index!;
    }
    if (mode != null && mode != setting.mode) {
      setting.mode = mode!;
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

  List<Map<String, Object?>> optionsToMap() {
    return [for (final option in options) option.toMap()];
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
  Map<String, Object?> diff(CustomerSettingOption option) {
    final result = <String, Object?>{};
    if (name != null && name != option.name) {
      option.name = name!;
      result['name'] = name!;
    }
    if (index != null && index != option.index) {
      option.index = index!;
      result['index'] = index!;
    }
    if (isDefault != null && isDefault != option.isDefault) {
      option.isDefault = isDefault!;
      result['isDefault'] = isDefault!;
    }
    if (modeValue != option.modeValue) {
      option.modeValue = modeValue;
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
