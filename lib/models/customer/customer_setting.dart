import 'package:possystem/services/database.dart';

import '../model.dart';
import '../objects/customer_object.dart';
import '../repository.dart';
import '../repository/customer_settings.dart';
import 'customer_setting_option.dart';

class CustomerSetting extends Model<CustomerSettingObject>
    with
        ModelOrderable<CustomerSettingObject>,
        ModelDB<CustomerSettingObject>,
        Repository<CustomerSettingOption>,
        RepositoryDB<CustomerSettingOption>,
        RepositoryOrderable<CustomerSettingOption> {
  static const TABLE = 'customer_settings';

  static const OPTION_TABLE = 'customer_setting_options';

  CustomerSettingOptionMode mode;

  @override
  final String modelTableName = TABLE;

  @override
  final String repoTableName = OPTION_TABLE;

  CustomerSetting({
    String? id,
    String name = 'customer setting',
    int index = 0,
    this.mode = CustomerSettingOptionMode.statOnly,
    Map<String, CustomerSettingOption>? options,
  }) : super(id) {
    this.name = name;
    this.index = index;
    if (options != null) replaceItems(options);
  }

  factory CustomerSetting.fromObject(CustomerSettingObject object) {
    return CustomerSetting(
      id: object.id,
      name: object.name!,
      index: object.index!,
      mode: object.mode!,
    );
  }

  CustomerSettingOption? get defaultOption {
    try {
      return items.firstWhere((option) => option.isDefault);
    } catch (e) {
      return null;
    }
  }

  @override
  CustomerSettings get repository => CustomerSettings.instance;

  @override
  set repository(repo) {}

  bool get shouldHaveModeValue => mode != CustomerSettingOptionMode.statOnly;

  @override
  Future<CustomerSettingOption> buildItem(Map<String, Object?> value) async {
    final object = CustomerSettingOptionObject.build(value);
    return CustomerSettingOption.fromObject(object);
  }

  Future<void> clearDefault() async {
    final option = defaultOption;

    // `modeValue` must be set, avoid setting it to null
    await option?.update(CustomerSettingOptionObject(
      isDefault: false,
      modeValue: option.modeValue,
    ));
  }

  Future<int> clearModeValues() {
    for (final item in items) {
      item.modeValue = null;
    }

    return Database.instance.update(
      repoTableName,
      int.parse(id),
      {'modeValue': null},
      keyName: 'customerSettingId',
    );
  }

  @override
  Future<List<Map<String, Object?>>> fetchItems() {
    return Database.instance.query(
      repoTableName,
      where: 'customerSettingId = ? && isDelete = 0',
      whereArgs: [int.parse(id)],
    );
  }

  /// Update options' [modeValue] if [mode] changed
  @override
  Future<void> save(Map<String, Object?> data) async {
    await super.save(data);

    await clearModeValues();
  }

  @override
  CustomerSettingObject toObject() => CustomerSettingObject(
        id: id,
        name: name,
        index: index,
        mode: mode,
        options: items.map((e) => e.toObject()),
      );
}
