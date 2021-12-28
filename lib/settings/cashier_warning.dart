import 'package:possystem/models/repository/cashier.dart';
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

  CashierUpdateStatus shouldShow(CashierUpdateStatus status) {
    if (status == CashierUpdateStatus.ok ||
        value == CashierWarningTypes.hideAll) {
      return CashierUpdateStatus.ok;
    }

    if (status != CashierUpdateStatus.notEnough &&
        value == CashierWarningTypes.onlyNotEnough) {
      return CashierUpdateStatus.ok;
    }

    return status;
  }
}

enum CashierWarningTypes {
  showAll,
  onlyNotEnough,
  hideAll,
}
