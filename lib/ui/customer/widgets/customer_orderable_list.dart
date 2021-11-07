import 'package:flutter/material.dart';
import 'package:possystem/components/scaffold/reorderable_scaffold.dart';
import 'package:possystem/models/customer/customer_setting.dart';
import 'package:possystem/models/repository/customer_settings.dart';
import 'package:possystem/translator.dart';

class CustomerOrderableList extends StatelessWidget {
  const CustomerOrderableList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ReorderableScaffold(
      items: CustomerSettings.instance.itemList,
      title: S.customerSettingReorder,
      handleSubmit: (List<CustomerSetting> items) =>
          CustomerSettings.instance.reorderItems(items),
    );
  }
}
