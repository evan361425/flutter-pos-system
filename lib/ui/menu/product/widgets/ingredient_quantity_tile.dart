import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/icon_text.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/translator.dart';

import '../../../../routes.dart';

class IngredientQuantityTile extends StatelessWidget {
  final ProductQuantity quantity;

  const IngredientQuantityTile({
    Key? key,
    required this.quantity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Navigator.of(context).pushNamed(
        Routes.menuQuantity,
        arguments: quantity,
      ),
      title: Text(quantity.name),
      trailing: Text(quantity.amount.toString()),
      onLongPress: () => BottomSheetActions.withDelete<_Actions>(
        context,
        deleteValue: _Actions.delete,
        warningContent: Text(tt('delete_confirm', {'name': quantity.name})),
        deleteCallback: quantity.remove,
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Tooltip(
            message: tt('menu.quantity.label.additional_price'),
            child: IconText(
              text: quantity.additionalPrice.toString(),
              icon: Icons.loyalty_sharp,
            ),
          ),
          MetaBlock(),
          Tooltip(
            message: tt('menu.quantity.label.additional_cost'),
            child: IconText(
              text: quantity.additionalCost.toString(),
              icon: Icons.attach_money_sharp,
            ),
          ),
        ],
      ),
    );
  }
}

enum _Actions {
  delete,
}
