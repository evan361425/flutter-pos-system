import 'package:flutter/material.dart';
import 'package:possystem/components/card_tile.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helper/validator.dart';
import 'package:possystem/models/stock/ingredient_model.dart';
import 'package:possystem/models/repository/menu_model.dart';
import 'package:possystem/models/repository/stock_model.dart';
import 'package:provider/provider.dart';

class IngredientScreen extends StatefulWidget {
  IngredientScreen({Key key, this.ingredient}) : super(key: key);

  final IngredientModel ingredient;

  @override
  _IngredientScreenState createState() => _IngredientScreenState();
}

class _IngredientScreenState extends State<IngredientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  bool isSaving = false;
  String errorMessage;

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<MenuModel>();
    if (menu.isNotReady) return Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(KIcons.back),
        ),
        actions: [_trailingAction()],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(kPadding),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _nameField(),
                  _amountField(),
                ],
              ),
            ),
          ),
          if (widget.ingredient != null) ..._productList(),
        ],
      ),
    );
  }

  void _onSubmit() {
    if (isSaving || !_formKey.currentState.validate()) return;

    final name = _nameController.text;
    final stock = context.read<StockModel>();

    if (widget.ingredient?.name != name && stock.hasContain(name)) {
      return setState(() => errorMessage = '成份名稱重複');
    }

    setState(() {
      isSaving = true;
      errorMessage = null;
    });

    _updateIngredient(name, stock);
    Navigator.of(context).pop();
  }

  void _updateIngredient(String name, StockModel stock) {
    final amount = num.parse(_amountController.text);

    widget.ingredient?.update(name: name, amount: amount);

    stock.updateIngredient(
      widget.ingredient ?? IngredientModel(name: name, currentAmount: amount),
    );
  }

  List<Widget> _productList() {
    final products = context
        .read<MenuModel>()
        .productContainsIngredient(widget.ingredient.id);

    return [
      Divider(),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: kPadding),
        child: Text(
          '使用 ${widget.ingredient.name} 的產品',
          style: Theme.of(context).textTheme.caption,
        ),
      ),
      Expanded(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              for (var ingredient in products)
                CardTile(
                  title: Text(
                    '${ingredient.product.catalog.name} - ${ingredient.product.name}',
                  ),
                  // TODO: add link to product
                  onTap: () {},
                )
            ],
          ),
        ),
      )
    ];
  }

  Widget _trailingAction() {
    return isSaving
        ? CircularProgressIndicator()
        : TextButton(
            onPressed: () => _onSubmit(),
            child: Text('儲存'),
          );
  }

  Widget _nameField() {
    return TextFormField(
      controller: _nameController,
      textInputAction: TextInputAction.done,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: '成份名稱，起司',
        errorText: errorMessage,
        filled: false,
      ),
      autofocus: widget.ingredient == null,
      maxLength: 30,
      validator: Validator.textLimit('成份名稱', 30),
    );
  }

  Widget _amountField() {
    return TextFormField(
      controller: _amountController,
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: '庫存',
        errorText: errorMessage,
        filled: false,
      ),
      validator: Validator.positiveNumber('庫存'),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _nameController.text = widget.ingredient?.name;
    _amountController.text =
        widget.ingredient?.currentAmount?.toString() ?? '0';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
