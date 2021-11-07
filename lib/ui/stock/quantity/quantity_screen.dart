import 'package:flutter/material.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';

import 'widgets/quantity_list.dart';

class QuantityScreen extends StatelessWidget {
  const QuantityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final quantities = context.watch<Quantities>();

    navigateNewQuantity() =>
        Navigator.of(context).pushNamed(Routes.stockQuantityModal);

    final body = quantities.isEmpty
        ? Center(child: EmptyBody(onPressed: navigateNewQuantity))
        : SingleChildScrollView(
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: kSpacing2),
                child: HintText(S.totalCount(quantities.length)),
              ),
              QuantityList(quantities: quantities.itemList),
            ]),
          );

    return Scaffold(
      appBar: AppBar(
        title: Text(S.stockQuantityTitle),
        leading: const PopButton(),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('quantities.add'),
        onPressed: navigateNewQuantity,
        tooltip: S.menuQuantityCreate,
        child: const Icon(KIcons.add),
      ),
      body: body,
    );
  }
}
