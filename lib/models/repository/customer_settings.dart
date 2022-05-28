import 'package:flutter/foundation.dart';
import 'package:possystem/helpers/db_transferer.dart';
import 'package:possystem/models/customer/customer_setting.dart';
import 'package:possystem/models/objects/customer_object.dart';
import 'package:possystem/services/database.dart';

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

  bool get hasSelectableSetting => items.any((item) => item.isNotEmpty);

  List<CustomerSetting> get selectableItemList =>
      itemList.where((item) => item.isNotEmpty).toList();

  @override
  Future<CustomerSetting> buildItem(Map<String, Object?> value) async {
    final object = CustomerSettingObject.build(value);

    final cs = CustomerSetting.fromObject(object);
    await cs.initialize();

    return cs;
  }

  Future<int> generateCombinationId(
    Map<String, String> data,
  ) async {
    final id = await Database.instance.push(
      combinationTable,
      {'combination': DBTransferer.toCombination(data)},
    );

    return id;
  }

  Future<int?> getCombinationId(
    Map<String, String> data,
  ) async {
    final result = await Database.instance.query(
      combinationTable,
      columns: ['id'],
      where: 'combination = ?',
      whereArgs: [DBTransferer.toCombination(data)],
      limit: 1,
    );

    return result.isEmpty ? null : result.first['id'] as int;
  }

  @override
  Future<void> dropItems() async {
    await Database.instance.reset(optionTable);
    return super.dropItems();
  }
}
