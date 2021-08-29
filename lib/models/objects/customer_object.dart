import '../customer/customer_setting.dart';
import '../model_object.dart';

class CustomerSettingObject extends ModelObject<CustomerSetting> {
  final String? id;

  String? name;

  int? index;

  CustomerSettingOptionMode? mode;

  List<CustomerSettingOption>? options;

  CustomerSettingObject({
    this.id,
    this.name,
    this.index,
    this.mode,
    this.options,
  });

  factory CustomerSettingObject.build(Map<String, Object?> data) {
    final options = (data['options'] ?? []) as Iterable;

    return CustomerSettingObject(
      id: data['id'] as String,
      name: data['name'] as String,
      index: data['index'] as int,
      mode: CustomerSettingOptionMode.values[data['mode'] as int],
      options:
          options.map((option) => CustomerSettingOption.build(option)).toList(),
    );
  }

  @override
  Map<String, Object> diff(CustomerSetting setting) {
    final result = <String, Object>{};
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
      final newModeVaule = setting.mode == CustomerSettingOptionMode.statOnly
          ? null
          : setting.mode == CustomerSettingOptionMode.changeDiscount
              ? 100
              : 0;
      result['$prefix.options'] =
          setting.options.map((e) => e.modeValue = newModeVaule).toList();
    }
    if (options != null && optionsIsChanged(setting.options)) {
      setting.options = options!;
      result['$prefix.options'] = options!.map((e) => e.toMap()).toList();
    }
    return result;
  }

  bool optionsIsChanged(List<CustomerSettingOption> others) {
    final length = options!.length;
    if (length != others.length) return true;

    for (var i = 0; i < length; i++) {
      if (options![i] != others[i]) return true;
    }

    return false;
  }

  @override
  Map<String, Object> toMap() {
    return {
      'id': id!,
      'name': name!,
      'index': index!,
      'mode': mode!.index,
      'options': options!.map((e) => e.toMap()).toList(),
    };
  }
}

class CustomerSettingOption {
  String name;

  bool isDefault;

  num? modeValue;

  CustomerSettingOption({
    required this.name,
    this.isDefault = false,
    this.modeValue,
  });

  factory CustomerSettingOption.build(Map<String, Object?> data) {
    return CustomerSettingOption(
      name: data['name'] as String,
      isDefault: data['isDefault'] as bool,
      modeValue: data['modeValue'] as num?,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is CustomerSettingOption &&
      other.name == name &&
      other.isDefault == isDefault &&
      other.modeValue == modeValue;

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'isDefault': isDefault,
      'modeValue': modeValue,
    };
  }

  @override
  String toString() => name;
}

enum CustomerSettingOptionMode {
  statOnly,
  changePrice,
  changeDiscount,
}
