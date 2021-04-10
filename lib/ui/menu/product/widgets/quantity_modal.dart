import 'package:flutter/material.dart';
import 'package:possystem/components/danger_button.dart';
import 'package:possystem/components/dialog/delete_dialog.dart';
import 'package:possystem/components/search_bar_inline.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helper/validator.dart';
import 'package:possystem/models/stock/quantity_model.dart';
import 'package:possystem/models/menu/product_ingredient_model.dart';
import 'package:possystem/models/menu/product_quantity_model.dart';

import 'quantity_search_scaffold.dart';

class QuantityModal extends StatefulWidget {
  QuantityModal({
    Key key,
    @required this.ingredient,
    this.quantity,
    this.quantityName,
  })  : isNew = quantity == null,
        super(key: key);

  final String quantityName;
  final ProductQuantityModel quantity;
  final ProductIngredientModel ingredient;
  final bool isNew;

  @override
  _QuantityModalState createState() => _QuantityModalState();
}

class _QuantityModalState extends State<QuantityModal> {
  final _formKey = GlobalKey<FormState>();
  final _ammountController = TextEditingController();
  final _additionalPriceController = TextEditingController();
  final _additionalCostController = TextEditingController();

  bool isSaving = false;
  String quantityName;
  String quantityId;
  String errorMessage;

  void _onSubmit() {
    final quantity = _getQuantityFromTextField();
    if (quantity == null) return;

    widget.quantity?.update(widget.ingredient, quantity);

    widget.ingredient.updateQuantity(quantity);

    Navigator.of(context).pop();
  }

  Future<void> _onDelete() async {
    final isDeleted = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return DeleteDialog(
          content: Text('此動作將無法復原'),
          onDelete: (BuildContext context) {
            widget.ingredient.removeQuantity(widget.quantity.id);
          },
        );
      },
    );
    if (isDeleted == true) Navigator.of(context).pop();
  }

  ProductQuantityModel _getQuantityFromTextField() {
    if (!_formKey.currentState.validate()) {
      return null;
    }
    if (quantityId.isEmpty) {
      setState(() => errorMessage = '必須設定成份份量名稱。');
      return null;
    }
    if (widget.quantity?.id != quantityId &&
        widget.ingredient.has(quantityId)) {
      setState(() => errorMessage = '成份份量重複。');
      return null;
    }

    return ProductQuantityModel(
      quantityId: quantityId,
      amount: num.parse(_ammountController.text),
      additionalPrice: num.parse(_additionalPriceController.text),
      additionalCost: num.parse(_additionalCostController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? '新增成份份量' : '設定成份份量「${widget.quantityName}」'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(KIcons.back),
        ),
        actions: [_trailingAction()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(kPadding),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _form(context),
              _deleteButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _deleteButton() {
    if (widget.isNew) return Container();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: kMargin),
      child: DangerButton(
        onPressed: _onDelete,
        child: Text('刪除份量 ${widget.quantityName}'),
      ),
    );
  }

  Widget _trailingAction() {
    return isSaving
        ? CircularProgressIndicator()
        : TextButton(
            onPressed: () => _onSubmit(),
            child: Text('儲存'),
          );
  }

  Widget _form(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          _nameSearchBar(),
          SizedBox(height: kMargin),
          TextFormField(
            controller: _ammountController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: '成分份量',
              filled: false,
            ),
            validator: Validator.positiveDouble('成分份量'),
          ),
          SizedBox(height: kMargin),
          TextFormField(
            controller: _additionalPriceController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.loyalty_sharp),
              labelText: '額外售價',
              filled: false,
            ),
            validator: Validator.isDouble('額外售價'),
          ),
          SizedBox(height: kMargin / 2),
          TextFormField(
            controller: _additionalCostController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.attach_money_sharp),
              labelText: '額外成本',
              filled: false,
            ),
            validator: Validator.isDouble('額外成本'),
          ),
        ],
      ),
    );
  }

  Widget _nameSearchBar() {
    return SearchBarInline(
      heroTag: QuantitySearchScaffold.tag,
      text: quantityName,
      hintText: '成份份量名稱，例如：少量',
      errorText: errorMessage,
      helperText: '新增成份份量後，可至庫存設定相關資訊',
      onTap: (BuildContext context) async {
        final quantity = await Navigator.of(context).push<QuantityModel>(
          MaterialPageRoute(
            builder: (_) => QuantitySearchScaffold(text: quantityName),
          ),
        );

        if (quantity != null) {
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

  void _updateByProportion(double proportion) {
    _ammountController.text =
        (widget.ingredient.defaultAmount * proportion).toString();
    _additionalPriceController.text =
        (widget.ingredient.product.price * proportion).toString();
    _additionalCostController.text =
        (widget.ingredient.product.cost * proportion).toString();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    quantityId = widget.quantity?.id ?? '';
    quantityName = widget.quantityName ?? '';
  }

  @override
  void initState() {
    _ammountController.text = widget.quantity?.amount?.toString();
    _additionalPriceController.text =
        widget.quantity?.additionalPrice?.toString();
    _additionalCostController.text =
        widget.quantity?.additionalCost?.toString();
    super.initState();
  }

  @override
  void dispose() {
    _ammountController.dispose();
    _additionalPriceController.dispose();
    _additionalCostController.dispose();
    super.dispose();
  }
}
