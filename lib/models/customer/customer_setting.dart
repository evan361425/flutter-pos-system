import 'package:possystem/services/database.dart';

import '../model.dart';
import '../objects/order_attribute_object.dart';
import '../repository.dart';
import '../repository/customer_settings.dart';
import 'customer_setting_option.dart';

class CustomerSetting extends Model<OrderAttributeObject>
    with
        ModelOrderable<OrderAttributeObject>,
        ModelDB<OrderAttributeObject>,
        Repository<CustomerSettingOption>,
        RepositoryDB<CustomerSettingOption>,
        RepositoryOrderable<CustomerSettingOption> {
  static const table = 'customer_settings';

  static const optionTable = 'customer_setting_options';

  OrderAttributeMode mode;

  @override
  final String modelTableName = table;

  @override
  final String repoTableName = optionTable;

  CustomerSetting({
    String? id,
    ModelStatus? status,
    String name = 'customer setting',
    int index = 0,
    this.mode = OrderAttributeMode.statOnly,
    Map<String, CustomerSettingOption>? options,
  }) : super(id, status) {
    this.name = name;
    this.index = index;
    if (options != null) replaceItems(options);
  }

  factory CustomerSetting.fromObject(OrderAttributeObject object) {
    return CustomerSetting(
      id: object.id,
      name: object.name!,
      index: object.index!,
      mode: object.mode!,
    );
  }

  @override
  CustomerSettings get repository => CustomerSettings.instance;

  @override
  set repository(repo) {}

  @override
  Future<CustomerSettingOption> buildItem(Map<String, Object?> value) async {
    final object = OrderAttributeOptionObject.build(value);
    return CustomerSettingOption.fromObject(object);
  }

  @override
  Future<List<Map<String, Object?>>> fetchItems() {
    return Database.instance.query(
      repoTableName,
      where: 'customerSettingId = ? AND isDelete = 0',
      whereArgs: [int.parse(id)],
    );
  }

  @override
  OrderAttributeObject toObject() => OrderAttributeObject(
        id: id,
        name: name,
        index: index,
        mode: mode,
        options: items.map((e) => e.toObject()),
      );
}
