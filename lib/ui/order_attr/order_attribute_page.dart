import 'package:flutter/material.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/route_circular_button.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/breakpoint.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/order_attr/widgets/order_attribute_tile.dart';

class OrderAttributePage extends StatelessWidget {
  final bool withScaffold;

  const OrderAttributePage({super.key, this.withScaffold = true});

  @override
  Widget build(BuildContext context) {
    final body = ListenableBuilder(
      listenable: OrderAttributes.instance,
      builder: (context, child) => Center(child: _buildBody()),
    );

    if (withScaffold) {
      return Scaffold(
        appBar: AppBar(
          title: Text(S.orderAttributeTitle),
          leading: const PopButton(),
        ),
        body: body,
      );
    }

    return body;
  }

  Widget _buildBody() {
    if (OrderAttributes.instance.isEmpty) {
      return EmptyBody(
        content: S.orderAttributeEmptyBody,
        routeName: Routes.orderAttrNew,
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: Breakpoint.medium.max),
      child: ListView(padding: const EdgeInsets.only(bottom: kFABSpacing, top: kTopSpacing), children: <Widget>[
        Row(children: [
          Expanded(
            child: Center(child: HintText(S.totalCount(OrderAttributes.instance.length))),
          ),
          Material(
            elevation: 1.0,
            borderRadius: const BorderRadius.all(Radius.circular(6.0)),
            child: RouteIconButton(
              key: const Key('order_attributes.reorder'),
              tooltip: S.orderAttributeTitleReorder,
              route: Routes.orderAttrReorder,
              icon: const Icon(KIcons.reorder),
            ),
          ),
          const SizedBox(width: kHorizontalSpacing),
        ]),
        const SizedBox(height: kInternalSpacing),
        for (final attribute in OrderAttributes.instance.itemList) OrderAttributeTile(attr: attribute),
        RouteElevatedIconButton(
          key: const Key('order_attributes.add'),
          icon: const Icon(KIcons.add),
          label: S.orderAttributeTitleCreate,
          route: Routes.orderAttrNew,
        ),
      ]),
    );
  }
}
