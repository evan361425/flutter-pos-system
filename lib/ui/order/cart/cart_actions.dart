import 'package:flutter/material.dart';
import 'package:possystem/components/dialog/single_text_dialog.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/translator.dart';

class CartActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<_DialogItems>(
        hint: Text(tt('order.cart.action_hint')),
        onChanged: (option) async => showInputDialog(
          context,
          _DialogItem.fromEnum(option),
        ),
        items: <DropdownMenuItem<_DialogItems>>[
          DropdownMenuItem(
            value: _DialogItems.discount,
            child: Text(tt('order.cart.discount')),
          ),
          DropdownMenuItem(
            value: _DialogItems.price,
            child: Text(tt('order.cart.price')),
          ),
          DropdownMenuItem(
            value: _DialogItems.count,
            child: Text(tt('order.cart.count')),
          ),
          DropdownMenuItem(
            value: _DialogItems.free,
            onTap: () => Cart.instance.updateSelectedPrice(0),
            child: Text(tt('order.cart.free')),
          ),
          DropdownMenuItem(
            value: _DialogItems.delete,
            onTap: () => Cart.instance.removeSelected(),
            child: Text(tt('order.cart.delete')),
          ),
        ],
      ),
    );
  }

  Future<void> showInputDialog(BuildContext context, _DialogItem? item) async {
    if (item == null) return;

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
}

enum _DialogItems {
  discount,
  price,
  count,
  free,
  delete,
}

class _DialogItem {
  _DialogItem({
    required this.validator,
    required this.decoration,
    required this.action,
  });

  final String? Function(String?) validator;
  final InputDecoration decoration;
  final void Function(String) action;

  static _DialogItem? fromEnum(_DialogItems? type) {
    switch (type) {
      case _DialogItems.discount:
        return _DialogItem(
          validator: Validator.positiveInt(
            tt('order.cart.name.discount'),
            maximum: 100,
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
      case _DialogItems.price:
        return _DialogItem(
          validator: Validator.positiveNumber(tt('order.cart.name.price')),
          decoration: InputDecoration(
            hintText: tt('order.cart.hint.price'),
            suffix: Text(tt('order.cart.suffix.price')),
          ),
          action: (result) {
            Cart.instance.updateSelectedPrice(num.tryParse(result));
          },
        );
      case _DialogItems.count:
        return _DialogItem(
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
      default:
        return null;
    }
  }
}
