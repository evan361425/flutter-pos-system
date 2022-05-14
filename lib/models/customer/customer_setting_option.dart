import 'package:possystem/models/objects/customer_object.dart';
import 'package:possystem/settings/currency_setting.dart';

import '../model.dart';
import 'customer_setting.dart';

class CustomerSettingOption extends Model<CustomerSettingOptionObject>
    with
        ModelDB<CustomerSettingOptionObject>,
        ModelOrderable<CustomerSettingOptionObject> {
  static const table = 'customer_setting_options';

  /// Connect to parent model
  late CustomerSetting setting;

  bool isDefault;

  num? modeValue;

  CustomerSettingOption({
    String id = '0',
    ModelStatus? status,
    String name = 'customer setting option',
    int index = 0,
    this.isDefault = false,
    this.modeValue,
  }) : super(id, status) {
    this.name = name;
    this.index = index;
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

  factory CustomerSettingOption.fromRow(
    CustomerSetting? cs,
    CustomerSettingOption? ori,
    List<String> row,
  ) {
    final isDefault = row.length > 1 ? row[1] == 'true' : false;
    final modeValue = row.length > 2 ? num.tryParse(row[2]) : null;
    final status = ori == null
        ? ModelStatus.staged
        : (isDefault == ori.isDefault && modeValue == ori.modeValue
            ? ModelStatus.normal
            : ModelStatus.updated);

    return CustomerSettingOption(
      id: ori?.id ?? '0',
      name: row[0],
      isDefault: isDefault,
      modeValue: modeValue,
      index: ori?.index ?? cs?.newIndex ?? 0,
      status: status,
    );
  }

  @override
  String get modelTableName => table;

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
      final value = modeValue!.toCurrency();
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
      default:
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
