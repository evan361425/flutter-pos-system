import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/translator.dart';

class IngredientQuantityMetadata extends StatelessWidget {
  const IngredientQuantityMetadata({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacing3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(tt('menu.quantity.label.additional_price')),
              MetaBlock(),
              Text(tt('menu.quantity.label.additional_cost')),
            ],
          ),
          Text(tt('menu.quantity.label.amount')),
        ],
      ),
    );
  }
}
