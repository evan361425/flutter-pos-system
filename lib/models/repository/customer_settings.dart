import 'package:flutter/foundation.dart';
import 'package:possystem/helpers/db_transferer.dart';
import 'package:possystem/models/customer/customer_setting.dart';
import 'package:possystem/models/objects/customer_object.dart';
import 'package:possystem/services/database.dart';
import 'package:possystem/services/storage.dart';

import '../repository.dart';

class CustomerSettings extends ChangeNotifier
    with
        Repository<CustomerSetting>,
        NotifyRepository<CustomerSetting>,
        OrderablRepository<CustomerSetting>,
        DBRepository<CustomerSetting> {
  static const TABLE = 'customer_settings';

  static const OPTION_TABLE = 'customer_setting_options';

  static const COMBINATION_TABLE = 'customer_setting_combinations';

  static late CustomerSettings instance;

  @override
  final Stores storageStore = Stores.customers;

  @override
  final String tableName = TABLE;

  CustomerSettings() {
    initialize();

    CustomerSettings.instance = this;
  }

  bool get hasSelectableSetting => items.any((item) => item.isNotEmpty);

  List<CustomerSetting> get selectableItemList =>
      itemList.where((item) => item.isNotEmpty).toList();

  @override
  Future<void> addItemToStorage(CustomerSetting item) async {
    final object = item.toObject();
    final id = await Database.instance.push(TABLE, object.toMap());
    item.id = id.toString();

    for (final option in object.optionsToMap()) {
      option['customerSettingId'] = id;
      await Database.instance.push(OPTION_TABLE, option);
    }
  }

  @override
  Future<CustomerSetting> buildItem(Map<String, Object?> item) async {
    final options = await Database.instance.query(
      OPTION_TABLE,
      where: 'customerSettingId = ?',
      whereArgs: [item['id'] as int],
    );

    final object = CustomerSettingObject.build(item, options);

    return CustomerSetting.fromObject(object);
  }

  Future<String> generateCombinationId(
    Map<String, String> data,
  ) async {
    final id = await Database.instance.push(
      COMBINATION_TABLE,
      {'combination': DBTransferer.toCombination(data)},
    );

    return id.toString();
  }

  Future<String?> getCombinationId(
    Map<String, String> data,
  ) async {
    final result = await Database.instance.query(
      COMBINATION_TABLE,
      columns: ['id'],
      where: 'combination = ?',
      whereArgs: [DBTransferer.toCombination(data)],
      limit: 1,
    );

    return result.isEmpty ? null : (result.first['id'] as int).toString();
  }
}
