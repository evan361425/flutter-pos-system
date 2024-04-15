import 'package:flutter/material.dart';
import 'package:possystem/components/scaffold/reorderable_scaffold.dart';
import 'package:possystem/models/order/order_attribute.dart';
import 'package:possystem/models/order/order_attribute_option.dart';
import 'package:possystem/translator.dart';

class OrderAttributeOptionReorder extends StatelessWidget {
  final OrderAttribute attribute;

  const OrderAttributeOptionReorder({
    super.key,
    required this.attribute,
  });

  @override
  Widget build(BuildContext context) {
    return ReorderableScaffold<OrderAttributeOption>(
      items: attribute.itemList,
      title: S.orderAttributeOptionTitleReorder,
      handleSubmit: (items) => attribute.reorderItems(items),
    );
  }
}
