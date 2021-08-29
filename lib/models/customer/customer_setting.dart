import 'package:possystem/helpers/logger.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/objects/customer_object.dart';
import 'package:possystem/models/repository/customers.dart';
import 'package:possystem/services/storage.dart';

import '../model.dart';

class CustomerSetting
    with Model<CustomerSettingObject>, OrderableModel<CustomerSettingObject> {
  String? description;

  late final List<CustomerSettingOption> options;

  CustomerSetting({
    String? id,
    required String name,
    this.description,
    int index = 0,
    List<CustomerSettingOption>? options,
  }) {
    this.id = id ?? Util.uuidV4();
    this.name = name;
    this.index = index;
    this.options = options ?? <CustomerSettingOption>[];
  }

  factory CustomerSetting.fromObject(CustomerSettingObject object) {
    return CustomerSetting(
        name: object.name!,
        description: object.description,
        index: object.index!,
        options: object.options);
  }

  @override
  String get code => 'customers.setting';

  @override
  Stores get storageStore => Stores.customers;

  @override
  void removeFromRepo() => Customers.instance.removeItem(id);

  @override
  CustomerSettingObject toObject() => CustomerSettingObject(
      id: id,
      name: name,
      description: description,
      index: index,
      options: options);

  @override
  String toString() => name;

  @override
  Future<void> update(CustomerSettingObject object) async {
    final updateData = object.diff(this);

    if (updateData.isEmpty) return Future.value();

    info(toString(), '$code.update');

    return Storage.instance.set(storageStore, updateData);
  }
}
