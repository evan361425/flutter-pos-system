import 'package:flutter/material.dart';

class OrderProvider extends ChangeNotifier {
  static final OrderProvider instance = OrderProvider._();

  OrderProvider._();

  void ordered() => notifyListeners();
}
