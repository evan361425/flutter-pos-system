import 'package:flutter/foundation.dart';

dynamic checkNotifierCalled(ChangeNotifier notifier, Function() action) {
  var isFired = false;
  notifier.addListener(() {
    isFired = true;
  });

  final result = action();
  if (result is Future) {
    return result.then((value) => isFired);
  } else {
    return isFired;
  }
}
