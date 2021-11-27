import 'package:simple_tip/simple_tip.dart';

void disableTips() {
  TipGrouper.defaultStateManager = _StateManager();
}

class _StateManager extends StateManager {
  @override
  bool shouldShow(String groupId, TipItem item) {
    return false;
  }

  @override
  Future<void> tipRead(String groupId, TipItem item) {
    return Future.value();
  }
}
