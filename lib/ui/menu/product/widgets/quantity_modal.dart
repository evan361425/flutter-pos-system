import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/dialog/delete_dialog.dart';
import 'package:possystem/components/mixin/item_modal.dart';
import 'package:possystem/components/style/search_bar_inline.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/menu/product_ingredient_model.dart';
import 'package:possystem/models/menu/product_quantity_model.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/repository/quantity_repo.dart';
import 'package:possystem/models/stock/quantity_model.dart';
import 'package:possystem/ui/menu/menu_routes.dart';

import 'quantity_search_scaffold.dart';

class QuantityModal extends StatefulWidget {
  final ProductQuantityModel? quantity;
  final ProductIngredientModel ingredient;

  final bool isNew;
  QuantityModal({
    Key? key,
    this.quantity,
    required this.ingredient,
  })  : isNew = quantity == null,
        super(key: key);

  @override
  _QuantityModalState createState() => _QuantityModalState();
}

class _QuantityModalState extends State<QuantityModal>
    with ItemModal<QuantityModal> {
  final _amountController = TextEditingController();
  final _priceController = TextEditingController();
  final _costController = TextEditingController();

  String quantityName = '';
  String quantityId = '';

  @override
  List<Widget> get actions => widget.isNew
      ? const []
      : [
          IconButton(
            onPressed: () => showCircularBottomSheet(
              context,
              useRootNavigator: false,
              actions: [
                ListTile(
                  title: Text('刪除'),
                  leading: Icon(KIcons.delete, color: kNegativeColor),
                  onTap: () async {
                    // pop off sheet
                    Navigator.of(context).pop();
                    await _handleDelete();
                  },
                ),
              ],
            ),
            icon: Icon(KIcons.more),
          ),
        ];

  @override
  Widget? get title =>
      Text(widget.isNew ? '新增成份份量' : '設定成份份量「${widget.quantity!.name}」');

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
        heroTag: QuantitySearchScaffold.tag,
        text: quantityName,
        hintText: '成份份量名稱，例如：少量',
        errorText: errorMessage,
        helperText: '新增成份份量後，可至庫存設定相關資訊',
        onTap: _selectQuantity,
      ),
      TextFormField(
        controller: _amountController,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: '成分份量',
          filled: false,
        ),
        validator: Validator.positiveNumber('成分份量'),
      ),
      TextFormField(
        controller: _priceController,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.loyalty_sharp),
          labelText: '額外售價',
          filled: false,
        ),
        validator: Validator.isNumber('額外售價'),
      ),
      TextFormField(
        controller: _costController,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => handleSubmit(),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.attach_money_sharp),
          labelText: '額外成本',
          helperText: '若份量減少了，成本可以為負數',
          filled: false,
        ),
        validator: Validator.isNumber('額外成本'),
      )
    ];
  }

  @override
  void initState() {
    super.initState();

    if (!widget.isNew) {
      quantityId = widget.quantity!.id;
      quantityName = widget.quantity!.quantity.name;
      _amountController.text = widget.quantity!.amount.toString();
      _priceController.text = widget.quantity!.additionalPrice.toString();
      _costController.text = widget.quantity!.additionalCost.toString();
    }
  }

  @override
  Future<void> updateItem() async {
    final object = _parseObject();

    if (widget.isNew) {
      final quantity = ProductQuantityModel(
        quantity: QuantityRepo.instance.getItem(object.id!),
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
      return '必須設定成份份量名稱。';
    }
    if (widget.quantity?.id != quantityId &&
        widget.ingredient.hasItem(quantityId)) {
      return '成份份量重複。';
    }
  }

  Future<void> _handleDelete() async {
    final isDeleted = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return DeleteDialog(
          content: Text('此動作將無法復原'),
          onDelete: (_) => widget.quantity!.remove(),
        );
      },
    );
    if (isDeleted == true) Navigator.of(context).pop();
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
      MenuRoutes.productQuantitySearch,
      arguments: quantityName,
    );

    if (quantity != null && quantity is QuantityModel) {
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
