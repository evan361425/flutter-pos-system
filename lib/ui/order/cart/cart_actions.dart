import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/dialog/single_text_dialog.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/translator.dart';

class CartActions extends StatelessWidget {
  const CartActions({super.key});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      key: const Key('cart.action'),
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () => showActions(context),
      child: Text(S.orderCartActionBulk),
    );
  }

  static void actionHandler(BuildContext context, CartActionTypes type) async {
    _DialogItem item;
    switch (type) {
      case CartActionTypes.discount:
        item = _DialogItem(
          validator: Validator.positiveInt(
            S.orderCartActionDiscountLabel,
            maximum: 1000,
          ),
          decoration: InputDecoration(
            hintText: S.orderCartActionDiscountHint,
            helperText: S.orderCartActionDiscountHelper,
            helperMaxLines: 4,
            suffix: Text(S.orderCartActionDiscountSuffix),
          ),
          action: (result) {
            Cart.instance.selectedUpdateDiscount(int.tryParse(result));
          },
        );
        break;
      case CartActionTypes.price:
        item = _DialogItem(
          validator: Validator.positiveNumber(S.orderCartActionChangePriceLabel),
          decoration: InputDecoration(
            hintText: S.orderCartActionChangePriceHint,
            prefix: Text(S.orderCartActionChangePricePrefix),
            suffix: Text(S.orderCartActionChangePriceSuffix),
          ),
          action: (result) {
            Cart.instance.selectedUpdatePrice(num.tryParse(result));
          },
        );
        break;
      case CartActionTypes.count:
        item = _DialogItem(
          validator: Validator.positiveInt(
            S.orderCartActionChangeCountLabel,
            maximum: 10000,
            minimum: 1,
          ),
          decoration: InputDecoration(
            hintText: S.orderCartActionChangeCountHint,
            helperMaxLines: 4,
            suffix: Text(S.orderCartActionChangeCountSuffix),
          ),
          action: (result) {
            Cart.instance.selectedUpdateCount(int.tryParse(result));
          },
        );
        break;
      case CartActionTypes.delete:
        return Cart.instance.selectedRemove();
      case CartActionTypes.free:
        return Cart.instance.selectedUpdatePrice(0);
    }

    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => SingleTextDialog(
        validator: item.validator,
        decoration: item.decoration,
        keyboardType: TextInputType.number,
      ),
    );

    item.action(result ?? '');
  }

  static void showActions(BuildContext context) async {
    final type = await showCircularBottomSheet<CartActionTypes>(
      context,
      actions: <BottomSheetAction<CartActionTypes>>[
        BottomSheetAction(
          key: const Key('cart.action.discount'),
          leading: const Icon(Icons.loyalty_outlined),
          title: Text(S.orderCartActionDiscount),
          returnValue: CartActionTypes.discount,
        ),
        BottomSheetAction(
          key: const Key('cart.action.price'),
          leading: const Icon(Icons.attach_money_outlined),
          title: Text(S.orderCartActionChangePrice),
          returnValue: CartActionTypes.price,
        ),
        BottomSheetAction(
          key: const Key('cart.action.count'),
          leading: const Icon(Icons.exposure_outlined),
          title: Text(S.orderCartActionChangeCount),
          returnValue: CartActionTypes.count,
        ),
        BottomSheetAction(
          key: const Key('cart.action.free'),
          leading: const Icon(Icons.free_breakfast_outlined),
          title: Text(S.orderCartActionFree),
          returnValue: CartActionTypes.free,
        ),
        BottomSheetAction(
          key: const Key('cart.action.delete'),
          leading: const Icon(KIcons.delete),
          title: Text(S.orderCartActionDelete),
          returnValue: CartActionTypes.delete,
        ),
      ],
    );

    if (type != null) {
      if (context.mounted) {
        actionHandler(context, type);
      }
    }
  }
}

enum CartActionTypes {
  discount,
  price,
  count,
  free,
  delete,
}

class _DialogItem {
  final String? Function(String?) validator;
  final InputDecoration decoration;
  final void Function(String) action;

  _DialogItem({
    required this.validator,
    required this.decoration,
    required this.action,
  });
}
