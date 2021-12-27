import 'package:possystem/settings/setting.dart';

class CashierWarningSetting extends Setting<CashierWarningTypes> {
  @override
  String get key => 'feat.cashierWarning';

  @override
  void initialize() {
    value = CashierWarningTypes.values[service.get<int>(key) ?? 0];
  }

  @override
  Future<void> updateRemotely(CashierWarningTypes data) {
    return service.set<int>(key, value.index);
  }
}

enum CashierWarningTypes {
  showAll,
  onlyNotEnough,
  hideAll,
}
