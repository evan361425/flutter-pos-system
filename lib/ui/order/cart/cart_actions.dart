import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/dialog/single_text_dialog.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/translator.dart';

class CartActions extends StatelessWidget {
  static final List<BottomSheetAction> actions =
      <BottomSheetAction<CartActionTypes>>[
    BottomSheetAction(
      key: const Key('cart.action.discount'),
      leading: const Icon(Icons.loyalty_sharp),
      title: Text(S.orderCartActionsDiscount),
      returnValue: CartActionTypes.discount,
    ),
    BottomSheetAction(
      key: const Key('cart.action.price'),
      leading: const Icon(Icons.attach_money_sharp),
      title: Text(S.orderCartActionsChangePrice),
      returnValue: CartActionTypes.price,
    ),
    BottomSheetAction(
      key: const Key('cart.action.count'),
      leading: const Icon(Icons.exposure_sharp),
      title: Text(S.orderCartActionsChangeCount),
      returnValue: CartActionTypes.count,
    ),
    BottomSheetAction(
      key: const Key('cart.action.free'),
      leading: const Icon(Icons.free_breakfast_sharp),
      title: Text(S.orderCartActionsFree),
      returnValue: CartActionTypes.free,
    ),
    BottomSheetAction(
      key: const Key('cart.action.delete'),
      leading: const Icon(Icons.delete_sharp),
      title: Text(S.orderCartActionsDelete),
      returnValue: CartActionTypes.delete,
    ),
  ];

  const CartActions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      key: const Key('cart.action'),
      onPressed: () => showActions(context),
      child: Text(S.orderCartActionsBtn),
    );
  }

  static void actionHandler(BuildContext context, CartActionTypes type) async {
    _DialogItem item;
    switch (type) {
      case CartActionTypes.discount:
        item = _DialogItem(
          validator: Validator.positiveInt(
            S.orderCartActionsDiscountLabel,
            maximum: 1000,
          ),
          decoration: InputDecoration(
            hintText: S.orderCartActionsDiscountHint,
            helperText: S.orderCartActionsDiscountHelper,
            helperMaxLines: 4,
            suffix: Text(S.orderCartActionsDiscountSuffix),
          ),
          action: (result) {
            Cart.instance.updateSelectedDiscount(int.tryParse(result));
          },
        );
        break;
      case CartActionTypes.price:
        item = _DialogItem(
          validator:
              Validator.positiveNumber(S.orderCartActionsChangePriceLabel),
          decoration: InputDecoration(
            hintText: S.orderCartActionsChangePriceHint,
            suffix: Text(S.orderCartActionsChangePriceSuffix),
          ),
          action: (result) {
            Cart.instance.updateSelectedPrice(num.tryParse(result));
          },
        );
        break;
      case CartActionTypes.count:
        item = _DialogItem(
          validator: Validator.positiveInt(
            S.orderCartActionsChangeCountLabel,
            maximum: 10000,
            minimum: 1,
          ),
          decoration: InputDecoration(
            hintText: S.orderCartActionsChangeCountHint,
            helperMaxLines: 4,
            suffix: Text(S.orderCartActionsChangeCountSuffix),
          ),
          action: (result) {
            Cart.instance.updateSelectedCount(int.tryParse(result));
          },
        );
        break;
      case CartActionTypes.delete:
        return Cart.instance.removeSelected();
      case CartActionTypes.free:
        return Cart.instance.updateSelectedPrice(0);
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
      actions: actions,
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
