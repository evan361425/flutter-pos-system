import 'package:possystem/models/objects/customer_object.dart';
import 'package:possystem/providers/currency_provider.dart';

import '../model.dart';
import 'customer_setting.dart';

class CustomerSettingOption extends Model<CustomerSettingOptionObject>
    with
        ModelDB<CustomerSettingOptionObject>,
        ModelOrderable<CustomerSettingOptionObject> {
  static const TABLE = 'customer_setting_options';

  /// Connect to parent model
  late CustomerSetting setting;

  bool isDefault;

  num? modeValue;

  CustomerSettingOption({
    String id = '0',
    String name = 'customer setting option',
    int index = 0,
    this.isDefault = false,
    this.modeValue,
    CustomerSetting? setting,
  }) : super(id) {
    this.name = name;
    this.index = index;

    if (setting != null) this.setting = setting;
  }

  factory CustomerSettingOption.fromObject(CustomerSettingOptionObject object) {
    return CustomerSettingOption(
      id: object.id!,
      name: object.name!,
      index: object.index!,
      isDefault: object.isDefault!,
      modeValue: object.modeValue,
    );
  }

  @override
  String get modelTableName => TABLE;

  String get modeValueName {
    if (modeValue == null ||
        setting.mode == CustomerSettingOptionMode.statOnly) {
      return '';
    }

    if (setting.mode == CustomerSettingOptionMode.changeDiscount) {
      final value = modeValue!.toInt();
      return value == 0
          ? '使訂單免費'
          : value >= 100
              ? '增加 ${(value / 100).toStringAsFixed(2)} 倍'
              : '打 ${(value % 10) == 0 ? (value / 10).toStringAsFixed(0) : value} 折';
    } else {
      final value = CurrencyProvider.n2s(modeValue!);
      return modeValue! == 0
          ? ''
          : modeValue! > 0
              ? '增加 $value 元'
              : '減少 $value 元';
    }
  }

  @override
  CustomerSetting get repository => setting;

  @override
  set repository(repo) => setting = repo as CustomerSetting;

  /// Use [modeValue] to calculate correct final price in order.
  num calculatePrice(num price) {
    if (modeValue == null) return price;

    switch (setting.mode) {
      case CustomerSettingOptionMode.changeDiscount:
        return price * modeValue! / 100;
      case CustomerSettingOptionMode.changePrice:
        return price + modeValue!;
      case CustomerSettingOptionMode.statOnly:
        return price;
    }
  }

  @override
  CustomerSettingOptionObject toObject() => CustomerSettingOptionObject(
        id: id,
        name: name,
        index: index,
        isDefault: isDefault,
        modeValue: modeValue,
        customerSettingId: int.parse(setting.id),
      );
}
