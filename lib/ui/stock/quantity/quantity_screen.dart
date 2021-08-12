import 'package:flutter/material.dart';
import 'package:possystem/components/style/circular_loading.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/stock/quantity/widgets/quantity_list.dart';
import 'package:provider/provider.dart';

class QuantityScreen extends StatelessWidget {
  const QuantityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final quantities = context.watch<Quantities>();

    final navigateNewQuantity =
        () => Navigator.of(context).pushNamed(Routes.stockQuantityModal);

    final body = quantities.isReady
        ? quantities.isEmpty
            ? Center(child: EmptyBody(onPressed: navigateNewQuantity))
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: kSpacing2),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      QuantityList(quantities: quantities.itemList),
                    ],
                  ),
                ),
              )
        : CircularLoading();

    return Scaffold(
      appBar: AppBar(
        title: Text(tt('home.quantities')),
        leading: PopButton(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: navigateNewQuantity,
        tooltip: tt('stock.quantity.add'),
        child: Icon(KIcons.add),
      ),
      body: body,
    );
  }
}
