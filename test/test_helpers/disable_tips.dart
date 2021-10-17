import 'package:simple_tip/simple_tip.dart';

void disableTips() {
  OrderedTip.stateManager = _StateManager();
}

class _StateManager extends StateManager {
  @override
  bool shouldShow(String groupId, OrderedTipItem item) {
    return false;
  }

  @override
  Future<void> tipRead(String groupId, OrderedTipItem item) {
    return Future.value();
  }
}
