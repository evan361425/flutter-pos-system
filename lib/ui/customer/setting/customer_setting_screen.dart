import 'package:flutter/material.dart';
import 'package:possystem/models/customer/customer_setting.dart';

class CustomerSettingScreen extends StatelessWidget {
  final CustomerSetting setting;

  const CustomerSettingScreen({Key? key, required this.setting})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Text(setting.name));
  }
}
