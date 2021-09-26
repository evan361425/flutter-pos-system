import 'package:possystem/services/database.dart';

import '../model.dart';
import '../objects/customer_object.dart';
import '../repository.dart';
import '../repository/customer_settings.dart';
import 'customer_setting_option.dart';

class CustomerSetting extends NotifyModel<CustomerSettingObject>
    with
        OrderableModel<CustomerSettingObject>,
        DBModel<CustomerSettingObject>,
        Repository<CustomerSettingOption>,
        NotifyRepository<CustomerSettingOption>,
        OrderablRepository<CustomerSettingOption> {
  static const TABLE = 'customer_settings';

  static const OPTION_TABLE = 'customer_setting_options';

  CustomerSettingOptionMode mode;

  @override
  final String logCode = 'customers.setting';

  CustomerSetting({
    String? id,
    String name = 'customer setting',
    int index = 0,
    this.mode = CustomerSettingOptionMode.statOnly,
    Map<String, CustomerSettingOption>? options,
  }) : super(id) {
    this.name = name;
    this.index = index;
    replaceItems(options ?? <String, CustomerSettingOption>{});
  }

  factory CustomerSetting.fromObject(CustomerSettingObject object) {
    return CustomerSetting(
        id: object.id,
        name: object.name!,
        index: object.index!,
        mode: object.mode!,
        options: {
          for (var option in object.options)
            option.id!: CustomerSettingOption.fromObject(option)
        })
      .._prepareOptions();
  }

  CustomerSettingOption? get defaultOption {
    try {
      return items.firstWhere((option) => option.isDefault);
    } catch (e) {
      return null;
    }
  }

  bool get shouldHaveModeValue => mode != CustomerSettingOptionMode.statOnly;

  @override
  String get tableName => TABLE;

  @override
  Future<void> addItemToStorage(CustomerSettingOption item) async {
    final map = item.toObject().toMap();
    map['customerSettingId'] = int.parse(id);

    final optionId = await Database.instance.push(tableName, map);
    item.id = optionId.toString();
  }

  Future<void> clearDefault() async {
    final option = defaultOption;
    if (option == null) return;

    // `modeValue` must be set, avoid setting it to null
    await option.update(CustomerSettingOptionObject(
      isDefault: false,
      modeValue: option.modeValue,
    ));
  }

  @override
  void notifyItem() {
    notifyListeners();
    CustomerSettings.instance.notifyItem();
  }

  @override
  void removeFromRepo() => CustomerSettings.instance.removeItem(id);

  @override
  CustomerSettingObject toObject() => CustomerSettingObject(
        id: id,
        name: name,
        index: index,
        mode: mode,
        options: items.map((e) => e.toObject()),
      );

  /// Update options' [modeValue] if [mode] changed
  @override
  Future<void> updateItemToDB(Map<String, Object?> data) async {
    final intId = int.parse(id);
    await Database.instance.update(tableName, intId, data);

    if (data['mode'] == null) return;

    for (final item in items) {
      item.modeValue = null;
    }
    await Database.instance.update(
      OPTION_TABLE,
      intId,
      {'modeValue': null},
      keyName: 'customerSettingId',
    );
  }

  void _prepareOptions() => items.forEach((e) => e.setting = this);
}
