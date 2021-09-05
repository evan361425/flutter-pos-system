import 'package:possystem/services/storage.dart';

import '../model.dart';
import '../objects/customer_object.dart';
import '../repository.dart';
import '../repository/customer_settings.dart';
import 'customer_setting_option.dart';

class CustomerSetting extends NotifyModel<CustomerSettingObject>
    with
        OrderableModel<CustomerSettingObject>,
        Repository<CustomerSettingOption>,
        NotifyRepository<CustomerSettingOption>,
        OrderablRepository<CustomerSettingOption> {
  CustomerSettingOptionMode mode;

  @override
  final String logCode = 'customers.setting';

  @override
  final Stores storageStore = Stores.customers;

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
  Future<void> addItemToStorage(CustomerSettingOption option) {
    return Storage.instance.set(storageStore, {
      option.prefix: option.toObject().toMap(),
    });
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

  void _prepareOptions() => items.forEach((e) => e.setting = this);
}
