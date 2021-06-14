import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

dynamic checkNotifierCalled(
  ChangeNotifier notifier,
  Function() action, [
  Matcher? matcher,
]) {
  var isFired = false;
  void setter() {
    isFired = true;
    notifier.removeListener(setter);
  }

  notifier.addListener(setter);

  final result = action();
  if (result is Future) {
    return result.then((value) {
      if (matcher != null) {
        expect(value, matcher);
      }
      return isFired;
    });
  } else {
    if (matcher != null) {
      expect(result, matcher);
    }
    return isFired;
  }
}
