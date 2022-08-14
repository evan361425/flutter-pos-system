import 'package:flutter/material.dart';
import 'package:possystem/components/scaffold/reorderable_scaffold.dart';
import 'package:possystem/models/order/order_attribute.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/translator.dart';

class OrderAttributeReorder extends StatelessWidget {
  const OrderAttributeReorder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ReorderableScaffold(
      items: OrderAttributes.instance.itemList,
      title: S.orderAttributeReorder,
      handleSubmit: (List<OrderAttribute> items) =>
          OrderAttributes.instance.reorderItems(items),
    );
  }
}
