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
  final bool withScaffold;

  const OrderAttributePage({super.key, this.withScaffold = true});

  @override
  Widget build(BuildContext context) {
    final attrs = context.watch<OrderAttributes>();

    handleCreate() => context.pushNamed(Routes.orderAttrNew);

    final body = attrs.isEmpty
        ? Center(
            child: EmptyBody(
              onPressed: handleCreate,
              content: S.orderAttributeEmptyBody,
            ),
          )
        : OrderAttributeList(
            attributes: attrs.itemList,
            tailing: ElevatedButton.icon(
              onPressed: handleCreate,
              label: Text(S.orderAttributeTitleCreate),
              icon: const Icon(KIcons.add),
            ),
          );

    return withScaffold
        ? Scaffold(
            appBar: AppBar(
              title: Text(S.orderAttributeTitle),
              leading: const PopButton(),
              actions: const [_ReorderAction()],
            ),
            body: body,
          )
        : Column(children: [
            const Material(
              elevation: 1.0,
              borderRadius: BorderRadius.all(Radius.circular(6.0)),
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                _ReorderAction(),
              ]),
            ),
            const SizedBox(height: 12.0),
            body,
          ]);
  }
}

class _ReorderAction extends StatelessWidget {
  const _ReorderAction({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const Key('order_attributes.reorder'),
      tooltip: S.orderAttributeTitleReorder,
      onPressed: () => context.pushNamed(Routes.orderAttrReorder),
      icon: const Icon(KIcons.reorder),
    );
  }
}
