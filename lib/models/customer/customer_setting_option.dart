import 'package:possystem/models/objects/order_attribute_object.dart';

import '../model.dart';
import 'customer_setting.dart';

class CustomerSettingOption extends Model<OrderAttributeOptionObject>
    with
        ModelDB<OrderAttributeOptionObject>,
        ModelOrderable<OrderAttributeOptionObject> {
  static const table = 'customer_setting_options';

  /// Connect to parent model
  late CustomerSetting setting;

  bool isDefault;

  num? modeValue;

  CustomerSettingOption({
    String? id,
    ModelStatus? status,
    String name = 'customer setting option',
    int index = 0,
    this.isDefault = false,
    this.modeValue,
  }) : super(id, status) {
    this.name = name;
    this.index = index;
  }

  factory CustomerSettingOption.fromObject(OrderAttributeOptionObject object) {
    return CustomerSettingOption(
      id: object.id!,
      name: object.name!,
      index: object.index!,
      isDefault: object.isDefault!,
      modeValue: object.modeValue,
    );
  }

  @override
  String get modelTableName => table;

  @override
  CustomerSetting get repository => setting;

  @override
  set repository(repo) => setting = repo as CustomerSetting;

  @override
  OrderAttributeOptionObject toObject() => OrderAttributeOptionObject(
        id: id,
        name: name,
        index: index,
        isDefault: isDefault,
        modeValue: modeValue,
      );
}
