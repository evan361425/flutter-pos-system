import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';

import 'widgets/order_attribute_list.dart';

class OrderAttributePage extends StatelessWidget {
  const OrderAttributePage({super.key});

  @override
  Widget build(BuildContext context) {
    final attrs = context.watch<OrderAttributes>();

    handleCreate() => context.pushNamed(Routes.orderAttrNew);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.orderAttributeTitle),
        leading: const PopButton(),
        actions: [
          IconButton(
            key: const Key('order_attributes.reorder'),
            tooltip: S.orderAttributeReorder,
            onPressed: () => context.pushNamed(Routes.orderAttrReorder),
            icon: const Icon(KIcons.reorder),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: handleCreate,
        tooltip: S.orderAttributeCreate,
        child: const Icon(KIcons.add),
      ),
      body: attrs.isEmpty
          ? Center(
              child: EmptyBody(
              onPressed: handleCreate,
              helperText: S.orderAttributeHint,
            ))
          : OrderAttributeList(attrs.itemList),
    );
  }
}
