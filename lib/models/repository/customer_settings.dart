import 'package:flutter/foundation.dart';
import 'package:possystem/models/customer/customer_setting.dart';
import 'package:possystem/models/objects/order_attribute_object.dart';

import '../repository.dart';

class CustomerSettings extends ChangeNotifier
    with
        Repository<CustomerSetting>,
        RepositoryOrderable<CustomerSetting>,
        RepositoryDB<CustomerSetting> {
  static const table = 'customer_settings';

  static const optionTable = 'customer_setting_options';

  static const combinationTable = 'customer_setting_combinations';

  static late CustomerSettings instance;

  @override
  final String repoTableName = table;

  CustomerSettings() {
    instance = this;
  }

  @override
  Future<CustomerSetting> buildItem(Map<String, Object?> value) async {
    final object = OrderAttributeObject.build(value);

    final cs = CustomerSetting.fromObject(object);
    await cs.initialize();

    return cs;
  }
}
