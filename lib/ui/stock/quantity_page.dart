import 'package:flutter/material.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/route_buttons.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

import 'widgets/stock_quantity_list.dart';

class QuantityPage extends StatelessWidget {
  final bool withScaffold;

  const QuantityPage({super.key, this.withScaffold = true});

  @override
  Widget build(BuildContext context) {
    final body = ListenableBuilder(
      listenable: Quantities.instance,
      builder: (context, child) => Center(child: _buildBody(context)),
    );

    return withScaffold
        ? Scaffold(
            appBar: AppBar(
              title: Text(S.stockQuantityTitle),
              leading: const PopButton(),
            ),
            body: body,
          )
        : body;
  }

  Widget _buildBody(BuildContext context) {
    if (Quantities.instance.isEmpty) {
      return EmptyBody(
        content: S.stockQuantityEmptyBody,
        routeName: Routes.quantityNew,
      );
    }

    return StockQuantityList(
      quantities: Quantities.instance.itemList,
      tailing: RouteElevatedIconButton(
        key: const Key('quantity.add'),
        route: Routes.quantityNew,
        label: S.stockQuantityTitleCreate,
        icon: const Icon(KIcons.add),
      ),
    );
  }
}
