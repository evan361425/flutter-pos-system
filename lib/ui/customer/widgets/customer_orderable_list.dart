import 'package:flutter/material.dart';
import 'package:possystem/components/scaffold/reorderable_scaffold.dart';
import 'package:possystem/models/customer/customer_setting.dart';
import 'package:possystem/models/repository/customers.dart';

class CustomerOrderableList extends StatelessWidget {
  const CustomerOrderableList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ReorderableScaffold(
      items: Customers.instance.itemList,
      title: '重新排序',
      handleSubmit: (List<CustomerSetting> items) =>
          Customers.instance.reorderItems(items),
    );
  }
}
