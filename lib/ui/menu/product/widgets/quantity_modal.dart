import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/dialog/delete_dialog.dart';
import 'package:possystem/components/search_bar_inline.dart';
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

class _QuantityModalState extends State<QuantityModal> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _priceController = TextEditingController();
  final _costController = TextEditingController();

  bool isSaving = false;
  String quantityName = '';
  String quantityId = '';
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew
            ? '新增成份份量'
            : '設定成份份量「${widget.quantity!.quantity.name}」'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(KIcons.back),
        ),
        actions: _appBarTrailings(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(kSpacing3),
          child: _form(context),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _priceController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    if (!widget.isNew) {
      quantityId = widget.quantity!.id;
      quantityName = widget.quantity!.quantity.name;
      _amountController.text = widget.quantity!.amount.toString();
      _priceController.text = widget.quantity!.additionalPrice.toString();
      _costController.text = widget.quantity!.additionalCost.toString();
    }
    super.initState();
  }

  Iterable<Widget> _actions() {
    return [
      ListTile(
        title: Text('刪除'),
        leading: Icon(KIcons.delete, color: kNegativeColor),
        onTap: () async {
          Navigator.of(context).pop();
          await _handleDelete();
        },
      ),
    ];
  }

  List<Widget> _appBarTrailings() {
    final submit = TextButton(
      onPressed: () => _handleSubmit(),
      child: Text('儲存'),
    );

    return widget.isNew
        ? [submit]
        : [
            submit,
            IconButton(
              onPressed: () => showCircularBottomSheet(
                context,
                useRootNavigator: false,
                actions: _actions(),
              ),
              icon: Icon(KIcons.more),
            )
          ];
  }

  TextFormField _fieldAmount() {
    return TextFormField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: '成分份量',
        filled: false,
      ),
      validator: Validator.positiveNumber('成分份量'),
    );
  }

  TextFormField _fieldCost() {
    return TextFormField(
      controller: _costController,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.attach_money_sharp),
        labelText: '額外成本',
        filled: false,
      ),
      validator: Validator.isNumber('額外成本'),
    );
  }

  TextFormField _fieldPrice() {
    return TextFormField(
      controller: _priceController,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.loyalty_sharp),
        labelText: '額外售價',
        filled: false,
      ),
      validator: Validator.isNumber('額外售價'),
    );
  }

  Widget _fieldQuantity() {
    return SearchBarInline(
      heroTag: QuantitySearchScaffold.tag,
      text: quantityName,
      hintText: '成份份量名稱，例如：少量',
      errorText: errorMessage,
      helperText: '新增成份份量後，可至庫存設定相關資訊',
      onTap: (BuildContext context) async {
        final quantity = await Navigator.of(context).pushNamed(
          MenuRoutes.productQuantitySearch,
          arguments: quantityName,
        );

        if (quantity != null && quantity is QuantityModel) {
          print('User choose quantity: ${quantity.name}');
          setState(() {
            errorMessage = null;
            quantityId = quantity.id;
            quantityName = quantity.name;
            _updateByProportion(quantity.defaultProportion);
          });
        }
      },
    );
  }

  Widget _form(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          _fieldQuantity(),
          const SizedBox(height: kSpacing2),
          _fieldAmount(),
          const SizedBox(height: kSpacing2),
          _fieldPrice(),
          const SizedBox(height: kSpacing1),
          _fieldCost(),
        ],
      ),
    );
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

  Future<void> _handleSubmit() async {
    if (!_validate()) return;

    await _updateQuantity();

    Navigator.of(context).pop();
  }

  ProductQuantityObject _parseObject() {
    return ProductQuantityObject(
      id: quantityId,
      amount: num.parse(_amountController.text),
      additionalPrice: num.parse(_priceController.text),
      additionalCost: num.parse(_costController.text),
    );
  }

  void _updateByProportion(num proportion) {
    _amountController.text = (widget.ingredient.amount * proportion).toString();
  }

  Future<void> _updateQuantity() async {
    final object = _parseObject();

    if (widget.isNew) {
      final quantity = ProductQuantityModel(
        quantity: QuantityRepo.instance.getChild(object.id!),
        ingredient: widget.ingredient,
        amount: object.amount,
        additionalPrice: object.additionalPrice,
        additionalCost: object.additionalCost,
      );

      await quantity.ingredient.setQuantity(quantity);
    } else {
      await widget.quantity!.update(object);
    }
  }

  bool _validate() {
    if (isSaving || !_formKey.currentState!.validate()) return false;
    if (quantityId.isEmpty) {
      setState(() => errorMessage = '必須設定成份份量名稱。');
      return false;
    }
    if (widget.quantity?.id != quantityId &&
        widget.ingredient.exist(quantityId)) {
      setState(() => errorMessage = '成份份量重複。');
      return false;
    }

    setState(() {
      isSaving = true;
      errorMessage = null;
    });

    return true;
  }
}
