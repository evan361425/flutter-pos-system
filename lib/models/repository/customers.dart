import 'package:flutter/foundation.dart';
import 'package:possystem/models/customer/customer_setting.dart';
import 'package:possystem/models/objects/customer_object.dart';
import 'package:possystem/services/storage.dart';

import '../repository.dart';

class Customers extends ChangeNotifier
    with
        Repository<CustomerSetting>,
        NotifyRepository<CustomerSetting>,
        OrderablRepository<CustomerSetting>,
        InitilizableRepository<CustomerSetting> {
  static Customers instance = Customers();

  Customers() {
    initialize();

    Customers.instance = this;
  }

  @override
  String get itemCode => 'customers.setting';

  @override
  Stores get storageStore => Stores.customers;

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
