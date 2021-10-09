import 'package:flutter/material.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/hint_text.dart';
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

    final body = quantities.isEmpty
        ? Center(child: EmptyBody(onPressed: navigateNewQuantity))
        : SingleChildScrollView(
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: kSpacing2),
                child:
                    HintText(tt('total_count', {'count': quantities.length})),
              ),
              QuantityList(quantities: quantities.itemList),
            ]),
          );

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
