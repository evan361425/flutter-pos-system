import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/dialog/single_text_dialog.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/translator.dart';

class CartActions extends StatelessWidget {
  static final List<BottomSheetAction> actions =
      <BottomSheetAction<_ActionTypes>>[
    BottomSheetAction(
      key: const Key('cart.action.discount'),
      leading: const Icon(Icons.loyalty_sharp),
      title: Text(S.orderCartActionsDiscount),
      returnValue: _ActionTypes.discount,
    ),
    BottomSheetAction(
      key: const Key('cart.action.price'),
      leading: const Icon(Icons.attach_money_sharp),
      title: Text(S.orderCartActionsChangePrice),
      returnValue: _ActionTypes.price,
    ),
    BottomSheetAction(
      key: const Key('cart.action.count'),
      leading: const Icon(Icons.exposure_sharp),
      title: Text(S.orderCartActionsChangeCount),
      returnValue: _ActionTypes.count,
    ),
    BottomSheetAction(
      key: const Key('cart.action.free'),
      leading: const Icon(Icons.free_breakfast_sharp),
      title: Text(S.orderCartActionsFree),
      returnValue: _ActionTypes.free,
    ),
    BottomSheetAction(
      key: const Key('cart.action.delete'),
      leading: const Icon(Icons.delete_sharp),
      title: Text(S.orderCartActionsDelete),
      returnValue: _ActionTypes.delete,
    ),
  ];

  const CartActions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      key: const Key('cart.action'),
      onPressed: () => showActions(context),
      child: Text(S.orderCartActionsBtn),
    );
  }

  static void actionHandler(BuildContext context, _ActionTypes type) async {
    _DialogItem item;
    switch (type) {
      case _ActionTypes.discount:
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
      case _ActionTypes.price:
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
      case _ActionTypes.count:
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
      case _ActionTypes.delete:
        return Cart.instance.removeSelected();
      case _ActionTypes.free:
        return Cart.instance.updateSelectedPrice(0);
    }

    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => SingleTextDialog(
        validator: item.validator,
        decoration: item.decoration,
        initialValue: item.initialValue,
        keyboardType: TextInputType.number,
      ),
    );

    item.action(result ?? '');
  }

  static void showActions(BuildContext context) async {
    final type = await showCircularBottomSheet<_ActionTypes>(
      context,
      actions: actions,
    );

    if (type != null) {
      actionHandler(context, type);
    }
  }
}

enum _ActionTypes {
  discount,
  price,
  count,
  free,
  delete,
}

class _DialogItem {
  final String? Function(String?) validator;
  final InputDecoration decoration;
  final String? initialValue;
  final void Function(String) action;

  _DialogItem({
    required this.validator,
    required this.decoration,
    required this.action,
    this.initialValue,
  });
}
