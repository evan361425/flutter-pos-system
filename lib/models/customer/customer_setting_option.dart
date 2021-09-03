import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/objects/customer_object.dart';
import 'package:possystem/services/storage.dart';

import '../model.dart';
import 'customer_setting.dart';

class CustomerSettingOption
    with
        Model<CustomerSettingOptionObject>,
        OrderableModel<CustomerSettingOptionObject> {
  bool isDefault;

  num? modeValue;

  CustomerSetting? setting;

  CustomerSettingOption({
    String? id,
    String name = 'customer setting option',
    int index = 0,
    this.isDefault = false,
    this.modeValue,
    this.setting,
  }) {
    this.id = id ?? Util.uuidV4();
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

  @override
  String toString() => name;

  @override
  String get code => 'customers.setting.option';

  @override
  String get prefix => '${setting!.prefix}.options.$id';

  @override
  void removeFromRepo() => setting!.removeItem(id);

  @override
  Stores get storageStore => Stores.customers;

  @override
  CustomerSettingOptionObject toObject() => CustomerSettingOptionObject(
        id: id,
        name: name,
        index: index,
        isDefault: isDefault,
        modeValue: modeValue,
      );
}
