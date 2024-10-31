import 'package:flutter/material.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/route_buttons.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

import 'widgets/stock_quantity_list.dart';

class QuantitiesPage extends StatelessWidget {
  const QuantitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      key: const Key('quantities_page'),
      listenable: Quantities.instance,
      builder: (context, child) => _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (Quantities.instance.isEmpty) {
      return EmptyBody(
        content: S.stockQuantityEmptyBody,
        routeName: Routes.quantityCreate,
      );
    }

    return StockQuantityList(
      quantities: Quantities.instance.itemList,
      leading: Row(children: [
        Expanded(
          child: RouteElevatedIconButton(
            key: const Key('quantity.add'),
            route: Routes.quantityCreate,
            label: S.stockQuantityTitleCreate,
            icon: const Icon(KIcons.add),
          ),
        ),
      ]),
    );
  }
}
