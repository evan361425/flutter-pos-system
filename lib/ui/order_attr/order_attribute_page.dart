import 'package:flutter/material.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/route_buttons.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/order_attr/widgets/order_attribute_tile.dart';

class OrderAttributePage extends StatelessWidget {
  const OrderAttributePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      key: const Key('order_attributes_page'),
      listenable: OrderAttributes.instance,
      builder: (context, child) => _buildBody(),
    );
  }

  Widget _buildBody() {
    if (OrderAttributes.instance.isEmpty) {
      return EmptyBody(
        content: S.orderAttributeEmptyBody,
        routeName: Routes.orderAttrCreate,
      );
    }

    return ListView(padding: const EdgeInsets.only(bottom: kFABSpacing, top: kTopSpacing), children: <Widget>[
      Row(children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: kHorizontalSpacing),
            child: RouteElevatedIconButton(
              key: const Key('order_attributes.add'),
              icon: const Icon(KIcons.add),
              label: S.orderAttributeTitleCreate,
              route: Routes.orderAttrCreate,
            ),
          ),
        ),
      ]),
      Row(children: [
        Expanded(
          child: Center(child: HintText(S.totalCount(OrderAttributes.instance.length))),
        ),
        RouteIconButton(
          key: const Key('order_attributes.reorder'),
          label: S.orderAttributeTitleReorder,
          route: Routes.orderAttrReorder,
          icon: const Icon(KIcons.reorder),
          hideLabel: true,
        ),
        const SizedBox(width: kHorizontalSpacing),
      ]),
      const SizedBox(height: kInternalSpacing),
      for (final attribute in OrderAttributes.instance.itemList) OrderAttributeTile(attr: attribute),
    ]);
  }
}
