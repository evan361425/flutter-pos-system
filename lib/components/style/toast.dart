import 'package:fluttertoast/fluttertoast.dart';

class Toast {
  static Future<bool?> show(String message) {
    if (_debugMode) {
      return Future.value();
    }

    return Fluttertoast.showToast(msg: message);
  }

  static bool _debugMode = false;

  static void startDebug() => _debugMode = true;
}
