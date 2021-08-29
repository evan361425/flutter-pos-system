import 'package:flutter/material.dart';
import 'package:possystem/components/scaffold/reorderable_scaffold.dart';
import 'package:possystem/models/customer/customer_setting.dart';
import 'package:possystem/models/objects/customer_object.dart';

class CustomerSettingOrderableList extends StatelessWidget {
  final CustomerSetting setting;

  const CustomerSettingOrderableList({
    Key? key,
    required this.setting,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ReorderableScaffold(
      items: setting.options,
      title: '重新排序',
      handleSubmit: (List<CustomerSettingOption> items) =>
          setting.update(CustomerSettingObject(options: items)),
    );
  }
}
