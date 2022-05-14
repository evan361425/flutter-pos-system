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
  static const table = 'customer_settings';

  static const optionTable = 'customer_setting_options';

  CustomerSettingOptionMode mode;

  @override
  final String modelTableName = table;

  @override
  final String repoTableName = optionTable;

  CustomerSetting({
    String? id,
    ModelStatus? status,
    String name = 'customer setting',
    int index = 0,
    this.mode = CustomerSettingOptionMode.statOnly,
    Map<String, CustomerSettingOption>? options,
  }) : super(id, status) {
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

  factory CustomerSetting.fromRow(CustomerSetting? ori, List<String> row) {
    final mode = str2CustomerSettingOptionMode(row[1]);
    final status = ori == null
        ? ModelStatus.staged
        : (mode == ori.mode ? ModelStatus.normal : ModelStatus.updated);

    return CustomerSetting(
      id: ori?.id,
      name: row[0],
      index: ori?.index ?? CustomerSettings.instance.newIndex,
      mode: mode,
      status: status,
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
      where: 'customerSettingId = ? AND isDelete = 0',
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
