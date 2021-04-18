import 'package:flutter/material.dart';
import 'package:possystem/components/empty_body.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/repository/quantity_repo.dart';
import 'package:provider/provider.dart';

import 'quantity_list.dart';

class QuantityBoby extends StatelessWidget {
  const QuantityBoby({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final quantityIndex = context.watch<QuantityRepo>();
    if (quantityIndex.isNotReady) {
      return Center(child: CircularProgressIndicator());
    }
    if (quantityIndex.isEmpty) {
      return Center(child: EmptyBody('quantity.empty'));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kPadding / 2),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // TODO: search bar
            QuantityList(quantities: quantityIndex.quantitiesList),
          ],
        ),
      ),
    );
  }
}
