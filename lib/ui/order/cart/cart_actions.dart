import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:possystem/components/dialog/single_text_dialog.dart';
import 'package:possystem/helper/validator.dart';
import 'package:possystem/models/repository/cart_model.dart';

class CartActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<_DialogItems>(
        hint: Text('使所選物'),
        onChanged: (option) async => showInputDialog(
          context,
          _DialogItem.fromEnum(option),
        ),
        items: <DropdownMenuItem<_DialogItems>>[
          DropdownMenuItem(
            value: _DialogItems.discount,
            child: Text('打折'),
          ),
          DropdownMenuItem(
            value: _DialogItems.price,
            child: Text('變價'),
          ),
          DropdownMenuItem(
            value: _DialogItems.count,
            child: Text('變更數量'),
          ),
          DropdownMenuItem(
            onTap: () => CartModel.instance.updateSelectedPrice(0),
            child: Text('招待'),
          ),
          DropdownMenuItem(
            onTap: () => CartModel.instance.removeSelected(),
            child: Text('刪除'),
          ),
        ],
      ),
    );
  }

  Future<void> showInputDialog(BuildContext context, _DialogItem item) async {
    if (item == null) return;

    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => SingleTextDialog(
        validator: item.validator,
        decoration: item.decoration,
        keyboardType: TextInputType.number,
      ),
    );

    item.action(result);
  }
}

enum _DialogItems {
  discount,
  price,
  count,
}

class _DialogItem {
  _DialogItem({
    @required this.validator,
    @required this.decoration,
    @required this.isInt,
    @required this.action,
  });

  final String Function(String) validator;
  final InputDecoration decoration;
  final bool isInt;
  final void Function(String) action;

  static _DialogItem fromEnum(_DialogItems type) {
    switch (type) {
      case _DialogItems.discount:
        return _DialogItem(
          validator: Validator.positiveInt('折扣', maximum: 100),
          decoration: InputDecoration(
            hintText: '每項產品的折扣',
            helperText: '這裡的數字代表「折」，即，85 代表 85 折。若需要準確的價錢請用「變價」',
            helperMaxLines: 4,
            suffix: Text('折'),
          ),
          isInt: true,
          action: (result) =>
              CartModel.instance.updateSelectedDiscount(num.tryParse(result)),
        );
      case _DialogItems.price:
        return _DialogItem(
          validator: Validator.positiveNumber('變價'),
          decoration: InputDecoration(
            hintText: '每項產品的價錢',
            suffix: Text('元'),
          ),
          isInt: false,
          action: (result) =>
              CartModel.instance.updateSelectedPrice(int.tryParse(result)),
        );
      case _DialogItems.count:
        return _DialogItem(
          validator: Validator.positiveInt('數量', maximum: 10000),
          decoration: InputDecoration(
            hintText: '產品數量',
            helperMaxLines: 4,
            suffix: Text('個'),
          ),
          isInt: true,
          action: (result) =>
              CartModel.instance.updateSelectedCount(int.tryParse(result)),
        );
      default:
        return null;
    }
  }
}
