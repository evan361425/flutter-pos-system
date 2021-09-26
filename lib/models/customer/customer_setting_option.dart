import 'package:possystem/models/objects/customer_object.dart';
import 'package:possystem/services/storage.dart';

import '../model.dart';
import 'customer_setting.dart';

class CustomerSettingOption
    with
        Model<CustomerSettingOptionObject>,
        DBModel<CustomerSettingOptionObject>,
        OrderableModel<CustomerSettingOptionObject> {
  static const TABLE = 'customer_setting_options';

  /// Connect to parent model
  late CustomerSetting setting;

  bool isDefault;

  num? modeValue;

  @override
  final String logCode = 'customers.setting.option';

  @override
  final Stores storageStore = Stores.customers;

  CustomerSettingOption({
    String? id,
    String name = 'customer setting option',
    int index = 0,
    this.isDefault = false,
    this.modeValue,
    CustomerSetting? setting,
  }) {
    this.id = id ?? generateId();
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
  String get prefix => '${setting.prefix}.options.$id';

  @override
  String get tableName => TABLE;

  @override
  void handleUpdated() {
    setting.notifyItem();
  }

  @override
  void removeFromRepo() => setting.removeItem(id);

  @override
  CustomerSettingOptionObject toObject() => CustomerSettingOptionObject(
        id: id,
        name: name,
        index: index,
        isDefault: isDefault,
        modeValue: modeValue,
      );
}
