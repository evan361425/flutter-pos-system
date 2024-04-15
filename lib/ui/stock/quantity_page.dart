import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';

import 'widgets/stock_quantity_list.dart';

class QuantityPage extends StatelessWidget {
  const QuantityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final quantities = context.watch<Quantities>();

    handleCreate() => context.pushNamed(Routes.quantityNew);

    final body = quantities.isEmpty
        ? Center(
            child: EmptyBody(
            helperText: S.stockQuantityEmptyBody,
            onPressed: handleCreate,
          ))
        : StockQuantityList(quantities: quantities.itemList);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.stockQuantityTitleMain),
        leading: const PopButton(),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('quantity.add'),
        onPressed: handleCreate,
        tooltip: S.stockQuantityTitleCreate,
        child: const Icon(KIcons.add),
      ),
      body: body,
    );
  }
}
