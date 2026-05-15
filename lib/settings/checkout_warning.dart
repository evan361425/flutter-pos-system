import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/settings/setting.dart';

class CheckoutWarningSetting extends Setting<CheckoutWarningTypes> {
  static final CheckoutWarningSetting instance = ._();

  static const CheckoutWarningTypes defaultValue = .showAll;

  CheckoutWarningSetting._() {
    value = defaultValue;
  }

  // history reason for calling cashier
  @override
  String get key => 'feat.cashierWarning';

  @override
  void initialize() {
    value = CheckoutWarningTypes.values[service.get<int>(key) ?? defaultValue.index];
  }

  @override
  Future<void> updateRemotely(CheckoutWarningTypes data) {
    return service.set<int>(key, value.index);
  }

  CheckoutStatus shouldShow(CheckoutStatus status) {
    if (status == .ok || value == .hideAll) {
      return CheckoutStatus.ok;
    }

    if (status != .cashierNotEnough && value == .onlyNotEnough) {
      return CheckoutStatus.ok;
    }

    return status;
  }
}

enum CheckoutWarningTypes {
  /// show all warning
  ///
  /// when using small amount of money, it will show warning
  showAll,

  /// only show when cashier has not enough money
  onlyNotEnough,

  /// hide all warning
  hideAll,
}
