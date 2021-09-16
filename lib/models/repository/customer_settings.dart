import 'package:flutter/foundation.dart';
import 'package:possystem/models/customer/customer_setting.dart';
import 'package:possystem/models/objects/customer_object.dart';
import 'package:possystem/services/storage.dart';

import '../repository.dart';

class CustomerSettings extends ChangeNotifier
    with
        Repository<CustomerSetting>,
        NotifyRepository<CustomerSetting>,
        OrderablRepository<CustomerSetting>,
        InitilizableRepository<CustomerSetting> {
  static CustomerSettings instance = CustomerSettings();

  @override
  final Stores storageStore = Stores.customers;

  @override
  final String repositoryName = 'customerSettings';

  CustomerSettings() {
    initialize();

    CustomerSettings.instance = this;
  }

  bool get hasSelectableSetting => items.any((item) => item.isNotEmpty);

  List<CustomerSetting> get selectableItemList =>
      itemList.where((item) => item.isNotEmpty).toList();

  @override
  CustomerSetting buildModel(String id, Map<String, Object?> value) {
    return CustomerSetting.fromObject(
      CustomerSettingObject.build({
        'id': id,
        ...value,
      }),
    );
  }
}
