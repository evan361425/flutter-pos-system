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
    final options =
        (data['options'] ?? <String, Object?>{}) as Map<String, Object?>;

    return CustomerSettingObject(
      id: data['id'] as String,
      name: data['name'] as String,
      index: data['index'] as int,
      mode: CustomerSettingOptionMode.values[data['mode'] as int],
      options: options.entries.map<CustomerSettingOptionObject>(
          (e) => CustomerSettingOptionObject.build({
                'id': e.key,
                ...e.value as Map<String, Object?>,
              })),
    );
  }

  @override
  Map<String, Object?> diff(CustomerSetting setting) {
    final result = <String, Object?>{};
    final prefix = setting.prefix;
    if (name != null && name != setting.name) {
      setting.name = name!;
      result['$prefix.name'] = name!;
    }
    if (index != null && index != setting.index) {
      setting.index = index!;
      result['$prefix.index'] = index!;
    }
    if (mode != null && mode != setting.mode) {
      setting.mode = mode!;
      result['$prefix.mode'] = mode!.index;

      for (final item in setting.items) {
        item.modeValue = null;
        result['${item.prefix}.modeValue'] = null;
      }
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

class CustomerSettingOptionObject extends ModelObject<CustomerSettingOption> {
  final String? id;

  final String? name;

  final int? index;

  final bool? isDefault;

  final num? modeValue;

  const CustomerSettingOptionObject({
    this.id,
    this.name,
    this.index,
    this.isDefault,
    this.modeValue,
  });

  factory CustomerSettingOptionObject.build(Map<String, Object?> data) {
    return CustomerSettingOptionObject(
      id: data['id'] as String,
      name: data['name'] as String,
      index: data['index'] as int,
      isDefault: data['isDefault'] as bool,
      modeValue: data['modeValue'] as num?,
    );
  }

  @override
  Map<String, Object?> toMap() {
    return {
      'name': name,
      'index': index,
      'isDefault': isDefault,
      'modeValue': modeValue,
    };
  }

  @override
  Map<String, Object?> diff(CustomerSettingOption option) {
    final result = <String, Object?>{};
    final prefix = option.prefix;
    if (name != null && name != option.name) {
      option.name = name!;
      result['$prefix.name'] = name!;
    }
    if (index != null && index != option.index) {
      option.index = index!;
      result['$prefix.index'] = index!;
    }
    if (isDefault != null && isDefault != option.isDefault) {
      option.isDefault = isDefault!;
      result['$prefix.isDefault'] = isDefault!;
    }
    if (modeValue != option.modeValue) {
      option.modeValue = modeValue;
      result['$prefix.modeValue'] = modeValue;
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
