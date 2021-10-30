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
      title: Text(tt('order.cart.discount')),
      returnValue: _ActionTypes.discount,
    ),
    BottomSheetAction(
      key: const Key('cart.action.price'),
      leading: const Icon(Icons.attach_money_sharp),
      title: Text(tt('order.cart.price')),
      returnValue: _ActionTypes.price,
    ),
    BottomSheetAction(
      key: const Key('cart.action.count'),
      leading: const Icon(Icons.exposure_sharp),
      title: Text(tt('order.cart.count')),
      returnValue: _ActionTypes.count,
    ),
    BottomSheetAction(
      key: const Key('cart.action.free'),
      leading: const Icon(Icons.free_breakfast_sharp),
      title: Text(tt('order.cart.free')),
      returnValue: _ActionTypes.free,
    ),
    BottomSheetAction(
      key: const Key('cart.action.delete'),
      leading: const Icon(Icons.delete_sharp),
      title: Text(tt('order.cart.delete')),
      returnValue: _ActionTypes.delete,
    ),
  ];

  const CartActions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      key: const Key('cart.action'),
      onPressed: () => showActions(context),
      child: Text(tt('order.cart.action_hint')),
    );
  }

  static void actionHandler(BuildContext context, _ActionTypes type) async {
    _DialogItem item;
    switch (type) {
      case _ActionTypes.discount:
        item = _DialogItem(
          validator: Validator.positiveInt(
            tt('order.cart.name.discount'),
            maximum: 1000,
          ),
          decoration: InputDecoration(
            hintText: tt('order.cart.hint.discount'),
            helperText: tt('order.cart.helper.discount'),
            helperMaxLines: 4,
            suffix: Text(tt('order.cart.suffix.discount')),
          ),
          action: (result) {
            Cart.instance.updateSelectedDiscount(int.tryParse(result));
          },
        );
        break;
      case _ActionTypes.price:
        item = _DialogItem(
          validator: Validator.positiveNumber(tt('order.cart.name.price')),
          decoration: InputDecoration(
            hintText: tt('order.cart.hint.price'),
            suffix: Text(tt('order.cart.suffix.price')),
          ),
          action: (result) {
            Cart.instance.updateSelectedPrice(num.tryParse(result));
          },
        );
        break;
      case _ActionTypes.count:
        item = _DialogItem(
          validator: Validator.positiveInt(
            tt('order.cart.name.count'),
            maximum: 10000,
            minimum: 1,
          ),
          decoration: InputDecoration(
            hintText: tt('order.cart.hint.count'),
            helperMaxLines: 4,
            suffix: Text(tt('order.cart.suffix.count')),
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
  final void Function(String) action;
  _DialogItem({
    required this.validator,
    required this.decoration,
    required this.action,
  });
}
