import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/settings/setting.dart';

class CheckoutWarningSetting extends Setting<CheckoutWarningTypes> {
  // history reason for calling cashier
  @override
  String get key => 'feat.cashierWarning';

  @override
  void initialize() {
    value = CheckoutWarningTypes.values[service.get<int>(key) ?? 0];
  }

  @override
  Future<void> updateRemotely(CheckoutWarningTypes data) {
    return service.set<int>(key, value.index);
  }

  CheckoutStatus shouldShow(CheckoutStatus status) {
    if (status == CheckoutStatus.ok || value == CheckoutWarningTypes.hideAll) {
      return CheckoutStatus.ok;
    }

    if (status != CheckoutStatus.cashierNotEnough && value == CheckoutWarningTypes.onlyNotEnough) {
      return CheckoutStatus.ok;
    }

    return status;
  }
}

enum CheckoutWarningTypes {
  showAll,
  onlyNotEnough,
  hideAll,
}
