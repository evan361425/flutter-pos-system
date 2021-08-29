import '../customer/customer_setting.dart';
import '../model_object.dart';

class CustomerSettingObject extends ModelObject<CustomerSetting> {
  final String? id;

  String? name;

  String? description;

  int? index;

  List<CustomerSettingOption>? options;

  CustomerSettingObject({
    this.id,
    this.name,
    this.description,
    this.index,
    this.options,
  });

  @override
  Map<String, Object?> toMap() {
    return {
      'id': id!,
      'name': name!,
      'description': description,
      'index': index!,
      'options': options!.map((e) => e.toMap()).toList(),
    };
  }

  @override
  Map<String, Object> diff(CustomerSetting setting) {
    final result = <String, Object>{};
    final prefix = setting.prefix;
    if (name != null && name != setting.name) {
      setting.name = name!;
      result['$prefix.name'] = name!;
    }
    if (description != setting.description) {
      setting.description = description;
      result['$prefix.description'] = description!;
    }
    if (index != null && index != setting.index) {
      setting.index = index!;
      result['$prefix.index'] = index!;
    }
    return result;
  }

  factory CustomerSettingObject.build(Map<String, Object?> data) {
    final options = (data['options'] ?? []) as Iterable;

    return CustomerSettingObject(
      id: data['id'] as String,
      name: data['name'] as String,
      description: data['description'] as String?,
      index: data['index'] as int,
      options:
          options.map((option) => CustomerSettingOption.build(option)).toList(),
    );
  }
}

class CustomerSettingOption {
  String name;

  bool isDefault;

  CustomerSettingOptionMode mode;

  num? modeValue;

  CustomerSettingOption({
    required this.name,
    this.isDefault = false,
    this.mode = CustomerSettingOptionMode.statOnly,
    this.modeValue,
  });

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'isDefault': isDefault,
      'mode': mode.index,
      'modeValue': modeValue,
    };
  }

  factory CustomerSettingOption.build(Map<String, Object?> data) {
    return CustomerSettingOption(
      name: data['name'] as String,
      isDefault: data['isDefault'] as bool,
      mode: CustomerSettingOptionMode.values[data['mode'] as int],
      modeValue: data['modeValue'] as num?,
    );
  }
}

enum CustomerSettingOptionMode {
  statOnly,
  changePrice,
  changeDiscount,
}
