import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/dialog/delete_dialog.dart';
import 'package:possystem/components/mixin/item_modal.dart';
import 'package:possystem/components/style/search_bar_inline.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

class ProductQuantityModal extends StatefulWidget {
  final ProductQuantity? quantity;
  final ProductIngredient ingredient;

  final bool isNew;
  ProductQuantityModal({
    Key? key,
    this.quantity,
    required this.ingredient,
  })  : isNew = quantity == null,
        super(key: key);

  @override
  _ProductQuantityModalState createState() => _ProductQuantityModalState();
}

class _ProductQuantityModalState extends State<ProductQuantityModal>
    with ItemModal<ProductQuantityModal> {
  late TextEditingController _amountController;
  late TextEditingController _priceController;
  late TextEditingController _costController;

  String quantityName = '';
  String quantityId = '';

  @override
  List<Widget> get actions => widget.isNew
      ? const []
      : [
          IconButton(
            onPressed: () async {
              final result = await showCircularBottomSheet(
                context,
                actions: <BottomSheetAction>[
                  BottomSheetAction(
                    title: Text(tt('delete')),
                    leading: Icon(
                      KIcons.delete,
                      color: Theme.of(context).errorColor,
                    ),
                    onTap: (context) => Navigator.of(context).pop('delete'),
                  ),
                ],
              );

              await _actionHandlers(result);
            },
            icon: Icon(KIcons.more),
          ),
        ];

  @override
  Widget? get title => Text(tt(
      widget.isNew ? 'menu.quantity.add_title' : 'menu.quantity.edit_title',
      {'name': widget.quantity?.name ?? ''}));

  @override
  void dispose() {
    _amountController.dispose();
    _priceController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  List<Widget> formFields() {
    return [
      SearchBarInline(
        text: quantityName,
        labelText: tt('menu.quantity.label.name'),
        hintText: tt('menu.quantity.hint.name'),
        errorText: errorMessage,
        helperText: tt('menu.quantity.helper.name'),
        onTap: _selectQuantity,
      ),
      TextFormField(
        controller: _amountController,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: tt('menu.quantity.label.amount'),
          filled: false,
        ),
        validator: Validator.positiveNumber(tt('menu.quantity.label.amount')),
      ),
      TextFormField(
        controller: _priceController,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.loyalty_sharp),
          labelText: tt('menu.quantity.label.additional_price'),
          helperText: tt('menu.quantity.helper.additional_price'),
          helperMaxLines: 10,
          filled: false,
        ),
        validator: Validator.isNumber(
          tt('menu.quantity.label.additional_price'),
        ),
      ),
      TextFormField(
        controller: _costController,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => handleSubmit(),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.attach_money_sharp),
          labelText: tt('menu.quantity.label.additional_cost'),
          helperText: tt('menu.quantity.helper.additional_cost'),
          helperMaxLines: 10,
          filled: false,
        ),
        validator: Validator.isNumber(
          tt('menu.quantity.label.additional_cost'),
        ),
      )
    ];
  }

  @override
  void initState() {
    super.initState();

    final q = widget.quantity;
    _amountController = TextEditingController(text: q?.amount.toString());
    _priceController =
        TextEditingController(text: q?.additionalPrice.toString());
    _costController = TextEditingController(text: q?.additionalCost.toString());

    if (q != null) {
      quantityId = q.id;
      quantityName = q.name;
    }
  }

  @override
  Future<void> updateItem() async {
    final object = _parseObject();

    if (widget.isNew) {
      final quantity = ProductQuantity(
        quantity: Quantities.instance.getItem(object.id!),
        ingredient: widget.ingredient,
        amount: object.amount,
        additionalPrice: object.additionalPrice,
        additionalCost: object.additionalCost,
      );

      await quantity.ingredient.setItem(quantity);
    } else {
      await widget.quantity!.update(object);
    }

    Navigator.of(context).pop();
  }

  @override
  String? validate() {
    if (quantityId.isEmpty) {
      return tt('menu.quantity.error.name_empty');
    }
    if (widget.quantity?.id != quantityId &&
        widget.ingredient.hasItem(quantityId)) {
      return tt('menu.quantity.error.name_repeat');
    }
  }

  Future<void> _actionHandlers(String? selected) {
    switch (selected) {
      case 'delete':
        return _handleDelete();
      default:
        return Future.value();
    }
  }

  Future<void> _handleDelete() async {
    final isConfirmed = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteDialog(
        content: Text(tt('delete_confirm', {'name': widget.quantity!.name})),
      ),
    );
    if (isConfirmed == true) {
      await widget.quantity!.remove();
      Navigator.of(context).pop();
    }
  }

  ProductQuantityObject _parseObject() {
    return ProductQuantityObject(
      id: quantityId,
      amount: num.parse(_amountController.text),
      additionalPrice: num.parse(_priceController.text),
      additionalCost: num.parse(_costController.text),
    );
  }

  Future<void> _selectQuantity(BuildContext context) async {
    final quantity = await Navigator.of(context).pushNamed(
      Routes.menuQuantitySearch,
      arguments: quantityName,
    );

    if (quantity != null && quantity is Quantity) {
      setState(() {
        errorMessage = null;
        quantityId = quantity.id;
        quantityName = quantity.name;
        _updateByProportion(quantity.defaultProportion);
      });
    }
  }

  void _updateByProportion(num proportion) {
    _amountController.text = (widget.ingredient.amount * proportion).toString();
  }
}
